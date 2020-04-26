//
//  KoratLogger.swift
//  Logger
//
//  Created by Kazuki Yamamoto on 2020/02/24.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import AppKit
import KoratPlugin
import KoratFoundation

let log = Logger(label: "app.kymmt.KoratLogger")

class KoratLogger: NSObject, Plugin {
    let name: String = "Logger"
    
    private let korat: KoratAppProtocol
    
    required init(korat: KoratAppProtocol) {
        self.korat = korat
    }
    
    func loadViewController() -> NSViewController {
        return NSViewController()
    }
}
