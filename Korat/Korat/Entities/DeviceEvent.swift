//
//  DeviceEvent.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/12.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

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

    let device: MobileDevice
    let type: EventType
    let connectionType: ConnectionType
}
