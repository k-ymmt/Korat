//
//  KoratError.swift
//  KoratServerKit
//
//  Created by Kazuki Yamamoto on 2020/04/26.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

enum KoratError: Error {
    case deviceNotExists(udid: String)
    case alreadyFree
}
