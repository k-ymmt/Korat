//
//  LoggerInteractor.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

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
    
    private let udid: String
    private var disposable: Disposable!
    
    private var logReceivedCallback: ((LogMessage) -> Void)?
    
    init(udid: String, deviceCenter: MobileDeviceCenter) {
        self.udid = udid
        self.deviceCenter = deviceCenter
        print(udid)
        self.disposable = self.deviceCenter.subscribeEvent { [weak self] (event) in
            guard let self = self,
                event.udid == self.udid else {
                    return
            }
            print(event)
            switch event.type {
            case .add:
                self.deviceCenter.subscribeDeviceMessage(udid: udid) { [weak self] (data) in
                    guard let self = self else {
                        return
                    }
                    do {
                        let log = try Log(serializedData: data)
                        self.logReceivedCallback?(.init(
                            message: log.message,
                            date: Date(timeIntervalSince1970: log.time),
                            level: .init(log.level),
                            source: .init(file: log.source.file, function: log.source.function, line: log.source.line
                        )))
                    } catch {
                        print(error)
                    }
                }
            case .remove:
                // TODO
                break
            case .paired:
                break
            }
            
        }
    }
    
    func receivedLog(callback: @escaping (LogMessage) -> Void) {
        self.logReceivedCallback = callback
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
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
