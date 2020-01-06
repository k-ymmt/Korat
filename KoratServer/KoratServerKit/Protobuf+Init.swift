//
//  ProtobufExtension.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice

extension Device {
    init(udid: String, name: String?) {
        self.udid = udid
        self.name = name ?? ""
    }
}

extension SubscribeDeviceEventResponse {
    init(
        type: SubscribeDeviceEventResponse.EventType,
        udid: String,
        connectionType: SubscribeDeviceEventResponse.ConnectionType
    ) {
        self.type = type
        self.udid = udid
        self.connectionType = connectionType
    }
}

extension DeviceNameResponse {
    init(name: String) {
        self.name = name
    }
}

extension SubscribeDeviceEventResponse.EventType {
    init(type: MobileDevice.EventType) {
        switch type {
        case .add:
            self = .add
        case .remove:
            self = .remove
        case .paired:
            self = .paired
        }
    }
}

extension SubscribeDeviceEventResponse.ConnectionType {
    init(type: ConnectionType) {
        switch type {
        case .usbmuxd:
            self = .usbmuxd
        case .network:
            self = .network
        }
    }
}

extension SubscribeResponse {
    init(message: Data) {
        self.message = message
    }
}
