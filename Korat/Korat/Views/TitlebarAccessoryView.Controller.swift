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

final class TitlebarAccessoryViewController: NSViewController {
    @IBOutlet private weak var deviceListPopUpButton: NSPopUpButton!
    
    private var devices: [String: String] = [:]
    var a: ServerStreamingCall<SubscribeDeviceEventRequest, SubscribeDeviceEventResponse>!
    var client: MobileDeviceServiceServiceClient!

    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        client = MobileDeviceServiceServiceClient.init(connection: .init(configuration: .init(target: .hostAndPort("127.0.0.1", 6001), eventLoopGroup: MultiThreadedEventLoopGroup.init(numberOfThreads: 10))))
//
//        a = client.subscribeDeviceEvent(.init()) { (response) in
//            guard !response.udid.isEmpty else {
//                return
//            }
//            let udid = response.udid
//            print(udid)
//            switch response.type {
//            case .add:
//                var request = DeviceNameRequest()
//                request.udid = udid
//                let nameResponse = self.client.getDeviceName(request, callOptions: nil)
//
//                nameResponse.response.always({ (result) in
//                    switch result {
//                    case .success(let response):
//                        DispatchQueue.main.async {
//                            self.devices[udid] = response.name
//                            self.deviceListPopUpButton.addItem(withTitle: response.name)
//                        }
//                    case .failure(let error):
//                        print(error)
//                    }
//                })
//            case .remove:
//                guard let name = self.devices[response.udid] else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.devices.removeValue(forKey: response.udid)
//                    self.deviceListPopUpButton.removeItem(withTitle: name)
//                }
//            default:
//                break
//            }
//            
//        }
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
}

