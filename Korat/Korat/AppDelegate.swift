//
//  AppDelegate.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2019/12/27.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Cocoa
import SwiftUI
import SwiftiMobileDevice
import MobileDevice

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var windowController: MainWindowController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        // Create the window and set the content view.
        if let path = Bundle(for: type(of: self)).path(forResource: "KoratServer", ofType: nil) {
//            DispatchQueue.global().async {
//                let task = Process()
//                task.launchPath = path
//                task.launch()
//                task.waitUntilExit()
//                print(task.terminationReason)
//                print(task.terminationStatus)
//            }
        }
        
        
        MobileDevice.debug = true
        windowController = MainWindowController()
        windowController.window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class WindowController: NSWindowController {
    
}
