//
//  Device.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/12.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

struct MobileDevice {
    let name: String?
    let udid: String
}

extension MobileDevice: Hashable {
}
