//
//  MobileDeviceCenter.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice

protocol MobileDeviceCenter {
    func getDevice(udid: String) -> MobileDevice?
    func getDeviceList() -> [MobileDevice]
    func subscribeEvent(body: @escaping (SwiftiMobileDevice.MobileDevice.Event) -> Void)
    func unsubscribeEvent() throws
    func getDeviceName(udid: String) throws -> String?
}

class SwiftiMobileDeviceCenter: MobileDeviceCenter {
    static let instance = SwiftiMobileDeviceCenter()
    
    private let locker: NSRecursiveLock = NSRecursiveLock()
    private var deviceList: [String: MobileDevice] = [:]
    
    private init() {
    }
    
    func getDevice(udid: String) -> MobileDevice? {
        locker.lock()
        defer { locker.unlock() }
        return deviceList[udid]
    }
    
    func getDeviceList() -> [MobileDevice] {
        locker.lock()
        defer { locker.unlock() }
        return deviceList.values.map { $0 }
    }
    
    func subscribeEvent(body: @escaping (SwiftiMobileDevice.MobileDevice.Event) -> Void) {
        do {
            try SwiftiMobileDevice.MobileDevice.eventSubscribe { [weak self] (event) in
                guard let self = self, let udid = event.udid else {
                    return
                }
                do {
                    switch event.type {
                    case .add:
                        try self.appendPool(udid: udid)
                    case .remove:
                        self.removePool(udid: udid)
                    default:
                        break
                    }
                }
                body(event)
            }
        } catch {
            log.error(error)
        }
    }
    
    func unsubscribeEvent() throws {
        locker.lock()
        for device in deviceList.values {
            device.free()
        }
        deviceList.removeAll()
        locker.unlock()
        if let error = SwiftiMobileDevice.MobileDevice.eventUnsubscribe() {
            throw error
        }
    }
    
    func getDeviceName(udid: String) throws -> String? {
        var device = try SwiftiMobileDevice.Device(udid: udid)
        defer { device.free() }
        var client = try LockdownClient(device: device, withHandshake: true)
        defer { client.free() }
        return try client.getName()
    }
    
    private func appendPool(udid: String) throws {
        locker.lock()
        defer { locker.unlock() }
        guard !deviceList.keys.contains(udid) else {
            log.warning("\(udid) already exist")
            return
        }
        
        let device = try MobileDevice(udid: udid)
        deviceList[udid] = device
    }
    
    private func removePool(udid: String) {
        locker.lock()
        defer { locker.unlock() }
        
        deviceList.removeValue(forKey: udid)
    }
}
