//
//  MobileDeviceCenter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import NIO

protocol Disposable {
    func dispose()
}

struct Dispose: Disposable {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func dispose() {
        self.action()
    }
}

struct DeviceEvent {
    enum EventType {
        case add
        case remove
        case paired
    }
    enum ConnectionType {
        case usbmuxd
        case network
    }

    let udid: String
    let type: EventType
    let connectionType: ConnectionType
}

protocol MobileDeviceCenter {
    func subscribeEvent(callback: @escaping (DeviceEvent) -> Void) -> Disposable
    func subscribeDeviceMessage(udid: String, callback: @escaping (Data) -> Void)
}

class KoratMobileDeviceCenter: MobileDeviceCenter {
    static let `default` = KoratMobileDeviceCenter()
    
    private let client: MobileDeviceServiceServiceClient
    
    private let syncDispatchQueue = DispatchQueue(label: "MobileDeviceCenter.syncDispatchQueue")
    
    private var deviceEvents: [String: (DeviceEvent) -> Void] = [:]
    
    init() {
        self.client = MobileDeviceServiceServiceClient(connection: .init(
            configuration: .init(
                target: .hostAndPort("127.0.0.1", 6001),
                eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount))
            )
        )
        _ = self.client.subscribeDeviceEvent(.init()) { [weak self] (response) in
            guard let self = self,
                !response.udid.isEmpty,
                let type = DeviceEvent.EventType(response.type),
                let connectionType = DeviceEvent.ConnectionType(response.connectionType) else {
                    print("unknown event: \(response)")
                    return
            }

            let event = DeviceEvent(
                udid: response.udid,
                type: type,
                connectionType: connectionType
            )
            self.syncDispatchQueue.async {
                for (_, action) in self.deviceEvents {
                    action(event)
                }
            }
        }
    }
    
    func subscribeEvent(callback: @escaping (DeviceEvent) -> Void) -> Disposable {
        let uuid = UUID().uuidString
        syncDispatchQueue.async {
            self.deviceEvents[uuid] = callback
        }
        
        return Dispose { [weak self] in
            self?.syncDispatchQueue.async {
                self?.deviceEvents.removeValue(forKey: uuid)
            }
        }
    }
    
    func subscribeDeviceMessage(udid: String, callback: @escaping (Data) -> Void) {
        _ = client.subscribe(.init(udid: udid)) { (response) in
            callback(response.message)
        }.status.always({ (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let status):
                print(status)
            }
        })
    }
    
    deinit {
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
