//
//  MobileDeviceConnection.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2020/01/02.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import SwiftiMobileDevice
import NIO

private let headerSize: Int64 = 8

class MobileDeviceConnection {
    var referenceCount: UInt
    
    private var client: InternalMobileDeviceConnection
    
    init(client: InternalMobileDeviceConnection) {
        self.client = client
        self.referenceCount = 1
    }
    
    func start() throws {
        try client.start()
    }
    
    func receive(callback: @escaping (Data) -> Void) {
        client.receiveCallback = { [weak self] data in
            guard let self = self else {
                return
            }
            for received in self.parse(source: data) {
                callback(received)
            }
        }
    }
    
    func send(data: Data) throws {
        var count = Int64(data.count)
        let header = Data(bytes: &count, count: 8)
        try client.send(data: header + data)
    }
    
    private func parse(source: Data) -> [Data] {
        var buffer: [Data] = []
        var start: Int64 = 0
        var end: Int64 = start + headerSize
        let count = source.count
        
        while end < count {
            let header = source[start..<end]
            let l = header.withUnsafeBytes { (buffer) -> Int64? in
                buffer.load(as: Int64.self)
            }
            guard let length = l else {
                return buffer
            }
            
            let data = source[end..<end + length]
            buffer.append(data)
            start = end + length
            end = start + headerSize
        }
        
        return buffer
    }
    
    deinit {
        client.close()
    }
}

protocol InternalMobileDeviceConnection {
    var receiveCallback: ((Data) -> Void)? { get set }
    func start() throws
    func send(data: Data)  throws
    func close()
}

private let bufferSize = 1024

class InternalNativeMobileDeviceConnection: NSObject, InternalMobileDeviceConnection {
    var receiveCallback: ((Data) -> Void)?
    
    private var connection: Int32 = -1
    
    init(connection: Int32) {
        self.connection = connection
    }
    
    func start() throws {
        self.receive()
    }
    
    func receive() {
        while true {
            guard connection > -1 else {
                return
            }
            var buffer = Data()
            var bytes = [CChar](repeating: 0, count: bufferSize)
            while true {
                let recvBytes = recv(connection, &bytes, bufferSize, 0)
                guard recvBytes > -1 else {
                    log.error("recv error: \(String(errorNumber: errno))")
                    return
                }
                switch recvBytes {
                case 0:
                    if buffer.count == 0 {
                        // disconnected
                        return
                    }
                    break
                case bufferSize:
                    buffer += Data(bytes: &bytes, count: bufferSize)
                    continue
                default:
                    buffer += Data(bytes: &bytes, count: recvBytes)
                    break
                }
                break
            }
            
            self.receiveCallback?(buffer)
        }
    }
    
    func send(data: Data) throws {
        guard connection > -1 else {
            throw NSError.init(domain: NSPOSIXErrorDomain, code: Int(POSIXErrorCode.EINVAL.rawValue))
        }

        guard Darwin.send(connection, [UInt8](data), data.count, 0) > -1 else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
        }
    }
    
    func close() {
        guard connection > -1 else {
            return
        }
        Darwin.close(connection)
        connection = -1
    }
    
    deinit {
        close()
    }
}


