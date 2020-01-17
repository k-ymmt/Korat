//
//  DeviceListAccessoryPresenter.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/12.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine

protocol DeviceListAccessoryPresentable {
    func selectDevice(device: MobileDevice?)
    var selectedDevicePublisher: PropertyPublisher<MobileDevice?> { get }
    var subscribeDeviceEventPublisher: ActionPublisher<DeviceEvent> { get }
}

class DeviceListAccessoryPresenter: DeviceListAccessoryPresentable {
    private let interactor: DeviceListAccessoryInteractable
    
    private var canncellables: Set<AnyCancellable> = Set()
    
    @PropertyPublished(defaultValue: nil) var selectedDevicePublisher: PropertyPublisher<MobileDevice?>
    @ActionPublished var subscribeDeviceEventPublisher: ActionPublisher<DeviceEvent>
    
    init(interactor: DeviceListAccessoryInteractable) {
        self.interactor = interactor

        self.interactor.selectedDevicePublisher
            .bind(to: _selectedDevicePublisher)
            .store(in: &canncellables)
        self.interactor.subscribeDeviceEventPublisher
            .bind(to: _subscribeDeviceEventPublisher)
            .store(in: &canncellables)
    }
    
    func selectDevice(device: MobileDevice?) {
        interactor.selectDevice(device: device)
    }
}
