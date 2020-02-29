//
//  TitlebarAccessoryViewController.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import AppKit
import NIO
import GRPC
import Combine

final class DeviceListAccessoryViewController: NSViewController {
    @IBOutlet private weak var deviceListPopUpButton: NSPopUpButton!
    
    @ActionPublished var deviceSelected: ActionPublisher<String>
    
    private let presenter: DeviceListAccessoryPresentable
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private var devices: [MobileDevice] = []

    init(presenter: DeviceListAccessoryPresentable) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.subscribeDeviceEventPublisher
            .sink { [weak self] (event) in
                guard let self = self else {
                    return
                }
                switch event.type {
                case .add:
                    self.addDevice(event.device)
                case .remove:
                    self.removeDevice(event.device)
                default:
                    return
                }
        }.store(in: &cancellables)
    }
    
    func addDevice(_ device: MobileDevice) {
        DispatchQueue.main.async {
            guard !self.devices.contains(where: { $0.udid == device.udid }) else {
                return
            }
            
            self.devices.append(device)
            let item = NSMenuItem(
                title: device.name ?? device.udid,
                action: #selector(self.selectedItem(_:)),
                keyEquivalent: ""
            )
            item.target = self
            self.deviceListPopUpButton.menu?.addItem(item)
            
            guard self.devices.count == 1 else {
                return
            }
            self.presenter.selectDevice(device: device)
        }
    }
    
    func removeDevice(_ device: MobileDevice) {
        DispatchQueue.main.async {
            guard let index = self.devices.firstIndex(where: { $0.udid == device.udid }) else {
                return
            }
            self.devices.remove(at: index)
            
            if self.deviceListPopUpButton.indexOfSelectedItem == index {
                self.presenter.selectDevice(device: nil)
            }
            
            self.deviceListPopUpButton.menu?.removeItem(at: index)
            
            
        }
    }
    
    @objc
    private func selectedItem(_ sender: NSMenuItem) {
        deviceListPopUpButton.title = sender.title
        let index = deviceListPopUpButton.indexOfSelectedItem
        presenter.selectDevice(device: devices[index])
    }
    
    deinit {
        log.debug("\(String(describing: type(of: self))) deinit")
    }
}

