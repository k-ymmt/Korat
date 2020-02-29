//
//  MainRouter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/02/28.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import AppKit

protocol MainRoutable {
}

struct MainRouter: MainRoutable {
    static func assembleModules() -> NSViewController {
        let app = KoratApp.instance
        let interactor = MainInteractor(app: app)
        var router = MainRouter()
        let presenter = MainPresenter(interactor: interactor, router: router)
        let viewController = MainViewController(presenter: presenter)
        router.viewController = viewController
        
        return viewController
    }
    
    private var viewController: NSViewController?
}
