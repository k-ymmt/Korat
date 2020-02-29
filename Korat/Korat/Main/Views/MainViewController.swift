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
    @IBOutlet weak var nameListView: NSView!
    @IBOutlet private weak var contentView: NSView!
    
    private var contentViewController: NSViewController?
    
    private let presenter: MainPresentable
    
    private var cancellables: Set<AnyCancellable> = Set()

    init(presenter: MainPresentable) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.selectedDevice
            .sink { [weak self] device in
                self?.updateContentView(device: device)
        }.store(in: &cancellables)
    }
    
    private func updateContentView(device: MobileDevice?) {
        contentViewController?.view.removeFromSuperview()
        contentViewController?.removeFromParent()
        contentViewController = nil
        
        guard let device = device else {
            return
        }
        
        let contentViewController = LoggerRouter.assembleModules(udid: device.udid)
        self.contentViewController = contentViewController
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
        ])
    }
    
    deinit {
        log.debug("\(String(describing: type(of: self))) deinit")
    }
}
