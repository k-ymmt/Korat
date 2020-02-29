//
//  KoratServer.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import GRPC
import SwiftiMobileDevice
import KoratFoundation
import NIO

private let receiveLength = UInt32.max

public class KoratServer {
    let host: String
    let port: Int
    private var server: Server?
    private var group: EventLoopGroup?

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    public func start() throws {
        let group = MultiThreadedEventLoopGroup.init(numberOfThreads: 1)
        self.group = group
        server = try Server.start(configuration: .init(
            target: .hostAndPort(host, port),
            eventLoopGroup: group,
            serviceProviders: [MobileDeviceProvider(
                center: SwiftiMobileDeviceCenter.default,
                pool: SwiftiMobileDeviceConnectionPool.instance
            )]
        )).wait()
    }
    
    public func close() throws {
        guard let group = self.group,
            let server = self.server else {
                log.warning("server already closed")
                return
        }
        
        try server.close().wait()
        try group.syncShutdownGracefully()
        
        self.server = nil
        self.group = nil
    }
    
    deinit {
        do {
            try close()
        } catch {
            log.error(error)
        }
    }
}

class MobileDeviceProvider {
    private let center: MobileDeviceCenter
    private let pool: MobileDeviceConnectionPool
    
    init(center: MobileDeviceCenter, pool: MobileDeviceConnectionPool) {
        self.pool = pool
        self.center = center
    }
}

extension MobileDeviceProvider: MobileDeviceServiceProvider {
    func unsubscribeDeviceEvent(request: UnsubscribeDeviceEventRequest, context: StatusOnlyCallContext) -> EventLoopFuture<UnsubscribeDeviceEventResponse> {
        do {
            try center.unsubscribeEvent()
        } catch {
            log.error(error)
        }
        
        return context.eventLoop.makeSucceededFuture(.init())
    }
    
    func getDeviceList(request: DeviceListRequest, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceListResponse> {
        var response = DeviceListResponse()
        
        response.devices = center.getDeviceList().map { device in
            Device.with {
                $0.name = device.name ?? ""
                $0.udid = device.udid
            }
        }
        return context.eventLoop.makeSucceededFuture(response)
    }
    
    func subscribeDeviceEvent(request: SubscribeDeviceEventRequest, context: StreamingResponseCallContext<SubscribeDeviceEventResponse>) -> EventLoopFuture<GRPCStatus> {
        center.subscribeEvent { (device) in
            guard let udid = device.udid, let type = device.type, let connectionType = device.connectionType else {
                return
            }
            _ = context.sendResponse(.with {
                $0.udid = udid
                $0.type = SubscribeDeviceEventResponse.EventType(type: type)
                $0.connectionType = SubscribeDeviceEventResponse.ConnectionType(type: connectionType)
            })
        }
        return context.statusPromise.futureResult
        
    }
    
    func getDeviceName(request: DeviceNameRequest, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceNameResponse> {
        do {
            let name = try center.getDeviceName(udid: request.udid) ?? ""
            return context.eventLoop.makeSucceededFuture(.with { $0.name = name })
        } catch {
            log.error(error)
            return context.eventLoop.makeFailedFuture(error)
        }
    }
    
    func publish(context: UnaryResponseCallContext<PublishResponse>) -> EventLoopFuture<(StreamEvent<PublishRequest>) -> Void> {
        return context.eventLoop.makeSucceededFuture({ event in
            switch event {
            case .message(let request):
                log.debug("publish request")
                let udid = request.udid
                guard !udid.isEmpty, let data = request.message.data(using: .utf8) else {
                    return
                }
                do {
                    let connection = try self.pool.getOrCreateConnection(udid: udid)
                    try connection.send(data: data)
                } catch {
                    log.error(error)
                    context.responsePromise.fail(error)
                }
            case .end:
                break
            }
        })
    }
    
    func subscribe(request: SubscribeRequest, context: StreamingResponseCallContext<SubscribeResponse>) -> EventLoopFuture<GRPCStatus> {
        log.debug("subscribe start")
        let udid = request.udid
        guard !udid.isEmpty else {
            return context.eventLoop.makeFailedFuture(GRPCStatus(code: .invalidArgument, message: "udid is required not empty"))
        }
        do {
            let connection = try pool.getOrCreateConnection(udid: udid)
            connection.receive { (data) in
                log.debug("received value: \(String(data: data, encoding: .utf8) ?? "nil"))")
                _ = context.sendResponse(.with { $0.message = data })
            }
        } catch {
            log.error(error)
            context.statusPromise.fail(GRPCStatus(code: .internalError, message: "receive failed error: \(error)"))
        }
        
        return context.statusPromise.futureResult
    }
}

extension String {
    init(errorNumber: Int32) {
        guard let code = POSIXErrorCode(rawValue: errorNumber) else {
            self = "unknown"
            return
        }

        let error = POSIXError(code)
        
        self = "\(error.code.rawValue  ): \(error.localizedDescription)"
    }
}
