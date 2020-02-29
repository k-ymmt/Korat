//
//  MainViewController.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import AppKit
import Combine

final class MainViewController: NSViewController {
    @IBOutlet private weak var idevicesPopUpButton: NSPopUpButton!
    @IBOutlet private weak var contentView: NSView!
    
    private var vc: NSViewController?
    
    private var cancellables: Set<AnyCancellable> = Set()

    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        KoratApp.instance.deviceSelectedPublisher
            .sink { [weak self] device in
                guard let self = self else {
                    return
                }
                self.vc?.view.removeFromSuperview()
                self.vc?.removeFromParent()
                self.vc = nil
                
                guard let device = device else {
                    return
                }
                
                let contentViewController = LoggerRouter.assembleModules(udid: device.udid)
                self.vc = contentViewController
                contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.addChild(contentViewController)
                self.contentView.addSubview(contentViewController.view)
                NSLayoutConstraint.activate([
                    contentViewController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                    contentViewController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                    contentViewController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                    contentViewController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                ])
        }.store(in: &cancellables)
    }
    
    deinit {
        log.debug("\(String(describing: type(of: self))) deinit")
    }
}
