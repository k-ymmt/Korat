//
//  MobileDeviceCenter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import NIO
import Combine
import KoratFoundation
import KoratPlugin

typealias DeviceEvent = KoratPlugin.DeviceEvent
typealias Disposable = KoratPlugin.Disposable
typealias MobileDeviceCenter = KoratPlugin.MobileDeviceCenter
typealias MobileDevice = KoratPlugin.MobileDevice

struct Dispose: Disposable {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func dispose() {
        self.action()
    }
}

extension Disposable {
    func store(in set: inout Set<AnyCancellable>) {
        AnyCancellable {
            self.dispose()
        }.store(in: &set)
    }
}

class KoratMobileDeviceCenter: MobileDeviceCenter {
    static let `default` = KoratMobileDeviceCenter()
    
    private let client: MobileDeviceServiceServiceClient
    
    private let syncDispatchQueue = DispatchQueue(label: "MobileDeviceCenter.syncDispatchQueue")
    
    private var deviceEvents: [String: (DeviceEvent) -> Void] = [:]
    
    @EventPublished private var subscribeEventPublisher: AnyPublisher<DeviceEvent, Error>
    
    private var subscribeEventCallbacks: CallbackPool<Result<DeviceEvent, Error>>!
    private var subscribeDeviceMessageCallbacks: [String: CallbackPool<Result<(String, Data), Error>>] = [:]
    
    init() {
        self.client = MobileDeviceServiceServiceClient(connection: .init(
            configuration: .init(
                target: .hostAndPort("127.0.0.1", 6001),
                eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount))
            )
        )
        
        subscribeEventCallbacks = CallbackPool<Result<DeviceEvent, Error>> { [weak self] action in
            let status = self?.client.subscribeDeviceEvent(.init(), handler: { (response) in
                let udid = response.udid
                guard let self = self,
                    !udid.isEmpty,
                    let type = DeviceEvent.EventType(response.type),
                    let connectionType = DeviceEvent.ConnectionType(response.connectionType) else {
                        log.info("unknown event: \(response)")
                        return
                }
                
                guard type == .add else {
                    let event = DeviceEvent(
                        device: KoratPlugin.MobileDevice(name: nil, udid: udid),
                        type: type,
                        connectionType: connectionType
                    )
                    action(.success(event))
                    return
                }
                self.client.getDeviceName(.with { $0.udid = response.udid }).response.whenSuccess({ (response) in
                    action(.success(.init(
                        device: .init(name: response.name, udid: udid),
                        type: type,
                        connectionType: connectionType
                    )))
                })
            })
            status?.status.whenFailure { (error) in
                action(.failure(error))
            }
            return status?.status.eventLoop
        }
    }
    
    func subscribeEvent(callback: @escaping (Result<DeviceEvent, Error>) -> Void) -> Disposable {
        let id = subscribeEventCallbacks.add(callback)
        
        return Dispose { [weak self] in
            self?.subscribeEventCallbacks.remove(id: id)
        }
    }
    
    func subscribeDeviceMessage(udid: String, id: String, callback: @escaping (Result<Data, Error>) -> Void) -> Disposable {
        let pool: CallbackPool<Result<(String, Data), Error>>
        if let cache = subscribeDeviceMessageCallbacks[udid] {
            pool = cache
        } else {
            pool = CallbackPool { [weak self] action in
                let status = self?.client.subscribe(.with { $0.udid = udid }, handler: { (response) in
                    action(.success((response.id, response.message)))
                })
                status?.status.whenFailure({ (error) in
                    action(.failure(error))
                })
                return status?.status.eventLoop
            }
            subscribeDeviceMessageCallbacks[udid] = pool
        }

        let disposing = pool.add { result in
            switch result {
            case .success(let (id, data)):
                guard id == id else {
                    return
                }
                callback(.success(data))
            case .failure(let error):
                callback(.failure(error))
            }
        }
        return Dispose {
            pool.remove(id: disposing)
        }
    }
    
    deinit {
    }
}

class CallbackPool<T> {
    private var started: Bool = false
    private let subscribe: (@escaping (T) -> Void) -> EventLoop?
    private var callbacks: [String: (T) -> Void] = [:]
    private let lock: NSRecursiveLock = NSRecursiveLock()
    private var status: EventLoop?
    
    init(subscribe: @escaping (_ action: @escaping (T) -> Void) -> EventLoop?) {
        self.subscribe = subscribe
    }
    
    func close() {
        lock.lock()
        guard started else {
            return
        }
        do {
            try status?.close()
        } catch {
            log.error(error)
        }
        status = nil
        started = false
        callbacks.removeAll()
        lock.unlock()
    }
    
    func add(_ callback: @escaping (T) -> Void) -> String {
        let uuid = UUID().uuidString
        lock.lock()
        callbacks[uuid] = callback
        if callbacks.count == 1 {
            status = subscribe { [weak self] in
                self?.invoke(with: $0)
            }
            started = true
        }
        lock.unlock()
        return uuid
    }
    
    func remove(id: String) {
        lock.lock()
        if callbacks.removeValue(forKey: id) != nil {
            if callbacks.count == 0 {
                close()
            }
        }
        lock.unlock()
    }
    
    func invoke(with parameter: T) {
        lock.lock()
        for (_, callback) in callbacks {
            callback(parameter)
        }
        lock.unlock()
    }
    
    deinit {
        close()
    }
}

extension DeviceEvent.EventType {
    init?(_ type: SubscribeDeviceEventResponse.EventType) {
        switch type {
        case .add:
            self = .add
        case .remove:
            self = .remove
        case .paired:
            self = .paired
        default:
            return nil
        }
    }
}

extension DeviceEvent.ConnectionType {
    init?(_ type: SubscribeDeviceEventResponse.ConnectionType) {
        switch type {
        case .usbmuxd:
            self = .usbmuxd
        case .network:
            self = .network
        default:
            return nil
        }
    }
}
