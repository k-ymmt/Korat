//
//  MainViewController.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import AppKit

final class MainViewController: NSViewController {
    @IBOutlet private weak var idevicesPopUpButton: NSPopUpButton!
    @IBOutlet private weak var contentView: NSView!
    
    private var vc: NSViewController!

    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentViewController = LoggerRouter.assembleModules(udid: "37f376e36584638795be6be05d0b6e2d19569952")
        self.vc = contentViewController
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
}
