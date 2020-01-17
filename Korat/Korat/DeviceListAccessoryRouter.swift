//
//  MainRouter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/12.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import AppKit

protocol DeviceListAccessoryRoutable {
    
}

class DeviceListAccessoryRouter: DeviceListAccessoryRoutable {
    static func assembleModules() -> NSViewController {
        let interactor = DeviceListAccessoryInteractor(
            mobileCenter: KoratMobileDeviceCenter.default,
            app: KoratApp.instance
        )
        let presenter = DeviceListAccessoryPresenter(interactor: interactor)
        let viewController = DeviceListAccessoryViewController(presenter: presenter)
        let router = DeviceListAccessoryRouter()
        router.viewController = viewController
        
        return router.viewController
    }
    
    private var viewController: NSViewController!
    
    init() {
    }
}
