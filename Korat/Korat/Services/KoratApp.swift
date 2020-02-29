//
//  KoratApp.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/10.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import KoratPlugin
import Combine

final class KoratApp: KoratAppProtocol {
    static let instance: KoratAppProtocol = KoratApp()
    
    let mobileDeviceCenter: MobileDeviceCenter
    
    private let notifySelectedDeviceChanged: CurrentValueSubject<MobileDevice?, Never> = CurrentValueSubject(nil)
    
    init() {
        self.mobileDeviceCenter = KoratMobileDeviceCenter.default
    }
    
    func subscribeSelectedDeviceChanged(observer: @escaping (MobileDevice?) -> Void) -> Cancellable {
        notifySelectedDeviceChanged.sink(receiveValue: observer)
    }
    
    func selectDevice(_ device: MobileDevice?) {
        notifySelectedDeviceChanged.send(device)
    }
    
    
}
