//
//  LoggerPresenter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/04.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

protocol LoggerPresentable {
    var messages: PropertyPublisher<[LogMessage]> { get }
}

class LoggerPresenter: LoggerPresentable {
    private let interactor: LoggerInteractable
    private let router: LoggerRoutable
    
    @PropertyPublished(defaultValue: []) var messages: PropertyPublisher<[LogMessage]>
    
    init(interactor: LoggerInteractable, router: LoggerRoutable) {
        self.interactor = interactor
        self.router = router
        
        interactor.receivedLog { [weak self] (message) in
            self?._messages.value.append(message)
            self?._messages.forceNotify()
        }
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
}
