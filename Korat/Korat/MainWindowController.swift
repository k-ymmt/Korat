//
//  MainWindowController.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import AppKit

final class MainWindowController: NSWindowController {
    private let mainVC: MainViewController
    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.toolbar = NSToolbar()
        let v = NSTitlebarAccessoryViewController()
        v.layoutAttribute = .left
        let titlebarVC = TitlebarAccessoryViewController()
        v.addChild(titlebarVC)
        v.view = titlebarVC.view
        window.addTitlebarAccessoryViewController(v)
        window.setFrameAutosaveName("Main Window")
        mainVC = MainViewController()
        window.contentView = mainVC.view
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
