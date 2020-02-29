//
//  MainPresenter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/02/28.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation

protocol MainPresentable {
    var selectedDevice: PropertyPublisher<MobileDevice?> { get }
}

class MainPresenter: MainPresentable {
    private let interactor: MainInteractable
    private let router: MainRoutable
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @PropertyPublished(defaultValue: nil) var selectedDevice: PropertyPublisher<MobileDevice?>
    
    init(interactor: MainInteractable, router: MainRoutable) {
        self.interactor = interactor
        self.router = router
        
        self.interactor.subscribeSelectedDeviceChanged { [weak self] (device) in
            self?._selectedDevice.value = device
        }.store(in: &cancellables)
    }
}
