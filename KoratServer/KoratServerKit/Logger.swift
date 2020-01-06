//
//  Logger.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/31.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation

enum Logger {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY:MM:dd hh:mm:ss.SSSS"
        return formatter
    }()
    
    static func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(error.localizedDescription, file: file, function: function, line: line)
    }
    static func log(_ message: Any?, file: String = #file, function: String = #function, line: Int = #line) {
        let date = Date()
        
        print("> \(Self.dateFormatter.string(from: date)) - \(file.split(separator: "/").last!): \(function): \(line)\n\(message ?? "nil")\n")
    }
}
