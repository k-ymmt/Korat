//
//  DeviceListAccessoryInteractor.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/01/12.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import Combine
import KoratPlugin

protocol DeviceListAccessoryInteractable {
    var selectedDevicePublisher: PropertyPublisher<MobileDevice?> { get }
    var subscribeDeviceEventPublisher: ActionPublisher<DeviceEvent> { get }
    func selectDevice(device: MobileDevice?)
}

class DeviceListAccessoryInteractor: DeviceListAccessoryInteractable {
    private let mobileCenter: MobileDeviceCenter
    private let app: KoratAppProtocol
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @PropertyPublished(defaultValue: nil) var selectedDevicePublisher: PropertyPublisher<MobileDevice?>
    @ActionPublished var subscribeDeviceEventPublisher: ActionPublisher<DeviceEvent>

    init(mobileCenter: MobileDeviceCenter, app: KoratAppProtocol) {
        self.mobileCenter = mobileCenter
        self.app = app

        app.subscribeSelectedDeviceChanged { [weak self] (device) in
            self?._selectedDevicePublisher.value = device
        }.store(in: &cancellables)
        mobileCenter.subscribeEvent { [weak self] (result) in
            guard let event = try? result.get() else {
                return
            }

            self?._subscribeDeviceEventPublisher.send(event)
        }.store(in: &cancellables)
    }
    
    func selectDevice(device: MobileDevice?) {
        app.selectDevice(device)
    }
    
    deinit {
        log.debug("deinit \(String(describing: type(of: self)))")
    }
}
