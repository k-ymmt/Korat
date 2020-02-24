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

class KoratLogger: NSObject, Plugin {
    private let korat: Korat
    
    required init(korat: Korat) {
        self.korat = korat
    }
    
    func loadViewController() -> NSViewController {
        print("foo")
        return NSViewController()
    }
    
    
}
