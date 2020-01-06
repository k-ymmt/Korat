//
//  MobileDeviceCenter.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice

struct SwiftiDevice {
    var name: String? {
        do {
            var client = try LockdownClient(device: device, withHandshake: true)
            defer { client.free() }
            return try client.getName()
        } catch {
            Logger.error(error)
            return nil
        }
    }
    
    let udid: String
    private let device: SwiftiMobileDevice.Device
    
    init?(udid: String) {
        self.udid = udid
        do {
            device = try .init(udid: udid)
        } catch {
            Logger.error(error)
            return nil
        }
    }
}

final class MobileDeviceCenter {
    static let `default` = MobileDeviceCenter()
    
    private init() {
    }
    
    func getDeviceList() -> [SwiftiDevice] {
        do {
            let devices = try SwiftiMobileDevice.MobileDevice.getDeviceList()
            return devices.compactMap { SwiftiDevice(udid: $0) }
        } catch {
            Logger.error(error)
            return []
        }
    }
    
    func subscribeEvent(body: @escaping (MobileDevice.Event) -> Void) {
        do {
            try SwiftiMobileDevice.MobileDevice.eventSubscribe { (event) in
                body(event)
            }
        } catch {
            Logger.error(error)
        }
    }
    
    func getDeviceName(udid: String) throws -> String? {
        var device = try SwiftiMobileDevice.Device(udid: udid)
        defer { device.free() }
        var client = try LockdownClient(device: device, withHandshake: true)
        defer { client.free() }
        return try client.getName()
    }
}
