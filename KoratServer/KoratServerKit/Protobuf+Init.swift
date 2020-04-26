//
//  ProtobufExtension.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice
import KoratFoundation

extension SubscribeDeviceEventResponse.EventType {
    init(type: SwiftiMobileDevice.MobileDevice.EventType) {
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
