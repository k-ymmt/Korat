//
//  Logger.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2019/12/31.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import Logging

public typealias Logger = Logging.Logger

public extension Logger {
    @inlinable
    func error(
        _ error: @autoclosure () -> Error,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        self.log(
            level: .error, "\(error().localizedDescription)", metadata: metadata(),
            file: file, function: function, line: line
        )
    }
}
