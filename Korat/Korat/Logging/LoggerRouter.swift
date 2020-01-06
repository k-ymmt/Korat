//
//  LoggerRouter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import AppKit

protocol LoggerRoutable {
}

struct LoggerRouter: LoggerRoutable {
    static func assembleModules(udid: String) -> NSViewController {
        let deviceCenter = KoratMobileDeviceCenter.default
        let interactor = LoggerInteractor(udid: udid, deviceCenter: deviceCenter)
        var router = LoggerRouter()
        let presenter = LoggerPresenter(interactor: interactor, router: router)
        let viewController = LoggerViewController(presenter: presenter)
        router.viewController = viewController
        
        return viewController
    }
    
    private var viewController: NSViewController?
}
