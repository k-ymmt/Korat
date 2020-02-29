//
//  MainInteractor.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/02/28.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import KoratPlugin

protocol MainInteractable {
    func subscribeSelectedDeviceChanged(callback: @escaping (MobileDevice?) -> Void) -> Cancellable
}

class MainInteractor: MainInteractable {
    private let app: KoratAppProtocol
    
    init(app: KoratAppProtocol) {
        self.app = app
    }
    
    func subscribeSelectedDeviceChanged(callback: @escaping (MobileDevice?) -> Void) -> Cancellable {
        app.subscribeSelectedDeviceChanged(observer: callback)
    }
}
