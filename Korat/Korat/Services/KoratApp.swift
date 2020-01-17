//
//  KoratApp.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/10.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

protocol KoratAppProtocol {
    var deviceSelectedPublisher: PropertyPublisher<MobileDevice?> { get }
    func selectDevice(_ device: MobileDevice?)
}

class KoratApp: KoratAppProtocol {
    static let instance: KoratApp = KoratApp()

    @PropertyPublished<MobileDevice?>(defaultValue: nil) var deviceSelectedPublisher: PropertyPublisher<MobileDevice?>
    
    func selectDevice(_ device: MobileDevice?) {
        _deviceSelectedPublisher.value = device
    }
}
