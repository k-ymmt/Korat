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
import NIO

private let receiveLength = UInt32.max

public class KoratServer {
    let host: String
    let port: Int
    private var server: EventLoopFuture<Server>?

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    public func start() {
        server = Server.start(configuration: .init(target: .hostAndPort(host, port), eventLoopGroup: MultiThreadedEventLoopGroup.init(numberOfThreads: 1), serviceProviders: [MobileDeviceProvider()]))
    }
}

class MobileDeviceProvider {
}

extension MobileDeviceProvider: MobileDeviceServiceProvider {
    func unsubscribeDeviceEvent(request: UnsubscribeDeviceEventRequest, context: StatusOnlyCallContext) -> EventLoopFuture<UnsubscribeDeviceEventResponse> {
        if let error = MobileDevice.eventUnsubscribe() {
            print(error)
        }
        
        return context.eventLoop.makeSucceededFuture(.init())
    }
    
    func getDeviceList(request: DeviceListRequest, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceListResponse> {
        var response = DeviceListResponse()
        
        response.devices = MobileDeviceCenter.default.getDeviceList().map { Device(udid: $0.udid, name: $0.name) }
        return context.eventLoop.makeSucceededFuture(response)
    }
    
    func subscribeDeviceEvent(request: SubscribeDeviceEventRequest, context: StreamingResponseCallContext<SubscribeDeviceEventResponse>) -> EventLoopFuture<GRPCStatus> {
        MobileDeviceCenter.default.subscribeEvent { (device) in
            guard let udid = device.udid, let type = device.type, let connectionType = device.connectionType else {
                return
            }
            let response = SubscribeDeviceEventResponse(
                type: SubscribeDeviceEventResponse.EventType(type: type),
                udid: udid,
                connectionType: SubscribeDeviceEventResponse.ConnectionType(type: connectionType)
            )
            _ = context.sendResponse(response)
        }
        return context.statusPromise.futureResult
        
    }
    
    func getDeviceName(request: DeviceNameRequest, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceNameResponse> {
        do {
            let name = try MobileDeviceCenter.default.getDeviceName(udid: request.udid) ?? ""
            return context.eventLoop.makeSucceededFuture(.init(name: name))
        } catch {
            Logger.log(error.localizedDescription)
            return context.eventLoop.makeFailedFuture(error)
        }
    }
    
    func publish(context: UnaryResponseCallContext<PublishResponse>) -> EventLoopFuture<(StreamEvent<PublishRequest>) -> Void> {
        return context.eventLoop.makeSucceededFuture({ event in
            switch event {
            case .message(let request):
                Logger.log("publish request")
                let udid = request.udid
                guard !udid.isEmpty, let data = request.message.data(using: .utf8) else {
                    return
                }
                do {
                    let connection = try MobileDeviceConnectionPool.instance.getOrCreateConnection(udid: udid)
                    try connection.send(data: data)
                } catch {
                    Logger.log(error.localizedDescription)
                    context.responsePromise.fail(error)
                }
            case .end:
                break
            }
        })
    }
    
    func subscribe(request: SubscribeRequest, context: StreamingResponseCallContext<SubscribeResponse>) -> EventLoopFuture<GRPCStatus> {
        print("subscribe start")
        let udid = request.udid
        guard !udid.isEmpty else {
            return context.eventLoop.makeFailedFuture(GRPCStatus(code: .invalidArgument, message: "udid is required not empty"))
        }
        do {
            let connection = try MobileDeviceConnectionPool.instance.getOrCreateConnection(udid: udid)
            connection.receive { (data) in
                Logger.log("received value: \(String(data: data, encoding: .utf8) ?? "nil"))")
                _ = context.sendResponse(.init(message: data))
            }
        } catch {
            Logger.log(error.localizedDescription)
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
