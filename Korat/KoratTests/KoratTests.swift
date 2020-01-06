//
//  KoratTests.swift
//  KoratTests
//
//  Created by Kazuki Yamamoto on 2019/12/27.
//  Copyright © 2019 kymmt. All rights reserved.
//

import XCTest
@testable import Korat

class KoratTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        print(SwiftiMobileDeviceCenter.default.getDeviceList())
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
