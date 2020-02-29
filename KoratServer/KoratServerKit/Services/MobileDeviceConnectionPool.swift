//
//  MobileDeviceConnection.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/30.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice

private let defaultPort: UInt = 8555

protocol MobileDeviceConnectionPool {
    func getOrCreateConnection(udid: String) throws -> MobileDeviceConnection
    func release(udid: String)
}

class SwiftiMobileDeviceConnectionPool: MobileDeviceConnectionPool {
    static let instance: SwiftiMobileDeviceConnectionPool = .init()
    
    private let lock: NSRecursiveLock = NSRecursiveLock()
    private var pool: [String: MobileDeviceConnection] = [:]
    
    private init() {
    }
    
    func getOrCreateConnection(udid: String) throws -> MobileDeviceConnection {
        lock.lock()
        defer { lock.unlock() }
        if let connection = pool[udid] {
            log.debug("get pool")
            connection.referenceCount += 1
            return connection
        }
        
        let device = try SwiftiMobileDevice.Device(udid: udid)
        let c = try device.connect(port: defaultPort)
        let connection = MobileDeviceConnection(client:
            InternalNativeMobileDeviceConnection(connection: try c.getFileDescriptor())
        )
        
        pool[udid] = connection
        DispatchQueue.global().async {
            do {
            try connection.start()
            } catch {
                log.error(error)
            }
        }
        log.debug("create connection")
        return connection
    }
    
    func release(udid: String) {
        lock.lock()
        defer { lock.unlock() }
        guard let connection = pool[udid] else {
            return
        }
        
        connection.referenceCount -= 1
        
        if connection.referenceCount == 0 {
            pool.removeValue(forKey: udid)
        }
    }
}
