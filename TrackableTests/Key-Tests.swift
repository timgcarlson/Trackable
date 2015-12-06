//
//  Key-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 06/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

enum TestKeys : String, Key {
    enum Tests : String, Key {
        case test1
        case test2
    }
    case test1
}

class KeyTests : QuickSpec {
    override func spec() {
        describe("Key") {
            context("description") {
                it("should be generated based on namespace structure") {
                    expect(TestKeys.Tests.test1.description).to(equal("TrackableTests.TestKeys.Tests.test1"))
                    expect(TestKeys.Tests.test2.description).to(equal("TrackableTests.TestKeys.Tests.test2"))
                    expect(TestKeys.test1.description).to(equal("TrackableTests.TestKeys.test1"))
                }
            }
        }
    }
}