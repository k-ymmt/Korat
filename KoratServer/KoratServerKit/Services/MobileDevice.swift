//
//  MobileDevicePool.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2020/04/26.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine
import SwiftiMobileDevice

class MobileDevice {
    let udid: String
    private(set) var lockdown: LockdownClient?
    
    private var device: Device?
    
    init(udid: String) throws {
        self.udid = udid
        let device = try Device(udid: udid)
        self.device = device
        
        self.lockdown = try LockdownClient(device: device, withHandshake: true)
    }
    
    func free() {
        lockdown?.free()
        lockdown = nil
        device?.free()
        device = nil
    }
}

extension MobileDevice {
    func getDeviceName() throws -> String {
        guard let lockdown = lockdown else {
            throw KoratError.alreadyFree
        }
        return try lockdown.getName()
    }
    
    func startSyslogCapture(callback: @escaping (SyslogReceivedData) -> Void) throws -> Cancellable {
        guard let device = device, let lockdown = lockdown else {
            throw KoratError.alreadyFree
        }
        var service: LockdownService!
        var client: SyslogRelayClient!
        var disposable: Disposable!
        do {
            service = try lockdown.getService(service: .syslogRelay)
            client = try SyslogRelayClient(device: device, service: service)
            disposable = try client.startCaptureMessage(callback: callback)
        } catch {
            service?.free()
            client?.free()
            disposable?.dispose()
        }
        
        
        return AnyCancellable {
            disposable.dispose()
            client.free()
            service.free()
        }
    }
}
