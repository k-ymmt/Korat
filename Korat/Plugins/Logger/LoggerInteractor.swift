//
//  LoggerInteractor.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine
import KoratFoundation
import KoratPlugin

struct LogMessage {
    enum Level {
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case critical
    }
    
    struct Source {
        let file: String
        let function: String
        let line: Int32
    }
    
    let message: String
    let date: Date
    let level: Level
    let source: Source
}

protocol LoggerInteractable {
    func receivedLog(callback: @escaping (LogMessage) -> Void)                                                          
}

class LoggerInteractor: LoggerInteractable {
    let deviceCenter: MobileDeviceCenter
    
    private var udid: String?
    private var cancellable: Cancellable!
    
    private var logReceivedCallback: ((LogMessage) -> Void)?
    
    init(app: KoratAppProtocol) {
        self.deviceCenter = app.mobileDeviceCenter
        app.subscribeSelectedDeviceChanged { [weak self] (device) in
            guard let self = self else {
                return
            }
            guard let device = device else {
                self.cancellable?.cancel()
                return
            }
            
            let udid = device.udid
            guard self.udid != udid else {
                return
            }
            self.udid = udid
            
            self.cancellable = self.deviceCenter.subscribeDeviceMessage(udid: udid, id: "app.kymmt.Logger") { [weak self] (message) in
                switch message {
                case .success(let data):
                    guard let data = try? Log(serializedData: data) else {
                        return
                    }
                    self?.logReceivedCallback?(.init(
                        message: data.message,
                        date: Date(timeIntervalSince1970: data.time),
                        level: LogMessage.Level(data.level),
                        source: LogMessage.Source(data.source)
                        ))
                case .failure(let error):
                    log.error(error)
                }
            }
        }
    }
    
    func receivedLog(callback: @escaping (LogMessage) -> Void) {
        self.logReceivedCallback = callback
    }
}

extension LogMessage.Level {
    init(_ level: Log.LogLevel) {
        switch level {
        case .trace:
            self = .trace
        case .debug:
            self = .debug
        case .info:
            self = .info
        case .notice:
            self = .notice
        case .warning:
            self = .warning
        case .error:
            self = .error
        case .critical:
            self = .critical
        default:
            // FIXME
            self = .trace
        }
    }
}

extension LogMessage.Source {
    init(_ source: Log.Source) {
        self.file = source.file
        self.function = source.function
        self.line = source.line
    }
}
