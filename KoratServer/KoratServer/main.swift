//
//  main.swift
//  KoratServer
//
//  Created by Kazuki Yamamoto on 2019/12/29.
//  Copyright © 2019 kymmt. All rights reserved.
//

import Foundation
import KoratServerKit

let server = KoratServer(host: "localhost", port: 6001)

server.start()
print("Run Server")
CFRunLoopRun()
