//
//  Chainer-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik on 08/12/15.
//  Copyright © 2015 STRV. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

class ChainerTests : QuickSpec {
    
    enum TestEvents : String, Event {
        case Test
    }
    
    enum TestKeys : String, Key {
        enum Tests : String, Key {
            case bool
            case string
        }
        case double
    }
    
    override func spec() {
        beforeEach {
            trackEvent = nil
            ChainLink.responsibilityChainTable = [ObjectIdentifier : ChainLink]()
        }
        
        describe("ChainLink") {
            context("tracker") {
                it("should track event") {
                    let instanceProperties : Set<TrackedProperty> = [TestKeys.Tests.string ~>> "Hello", TestKeys.Tests.bool ~>> true]
                    let classProperties : Set<TrackedProperty> = [TestKeys.Tests.bool ~>> false]
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEvent = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    let link = ChainLink.Tracker(instanceProperties: instanceProperties, classProperties: { classProperties })
                    link.track(TestEvents.Test, trackedProperties:  [])
                    expect(receivedEventName).to(equal("TrackableTests.ChainerTests.TestEvents.Test"))
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.bool"] as? Bool).to(beTrue())
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.string"] as? String).to(equal("Hello"))
                }

                it("should track event when self is nil") {
                    let instanceProperties : Set<TrackedProperty> = [TestKeys.Tests.string ~>> "Hello", TestKeys.Tests.bool ~>> true]
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEvent = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    let link = ChainLink.Tracker(instanceProperties: instanceProperties, classProperties: { return nil} )
                    link.track(TestEvents.Test, trackedProperties:  [])
                    expect(receivedEventName).to(equal("TrackableTests.ChainerTests.TestEvents.Test"))
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.bool"] as? Bool).to(beTrue())
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.string"] as? String).to(equal("Hello"))
                }
            }

            context("chainer") {
                it("should call parent link") {
                    let instanceProperties : Set<TrackedProperty> = [TestKeys.Tests.string ~>> "Hello", TestKeys.Tests.bool ~>> true]
                    let classProperties : Set<TrackedProperty> = [TestKeys.Tests.bool ~>> false]
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEvent = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    let parentLink = ChainLink.Tracker(instanceProperties: [], classProperties: { return [] })
                    
                    let link = ChainLink.Chainer(instanceProperties: instanceProperties, classProperties: { classProperties }, parent: parentLink)
                    link.track(TestEvents.Test, trackedProperties:  [])
                    
                    expect(receivedEventName).to(equal("TrackableTests.ChainerTests.TestEvents.Test"))
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.bool"] as? Bool).to(beTrue())
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.string"] as? String).to(equal("Hello"))
                }

                it("should call parent link when self is nil") {
                    let instanceProperties : Set<TrackedProperty> = [TestKeys.Tests.string ~>> "Hello", TestKeys.Tests.bool ~>> true]
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEvent = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    let parentLink = ChainLink.Tracker(instanceProperties: [], classProperties: { return [] })
                    
                    let link = ChainLink.Chainer(instanceProperties: instanceProperties, classProperties: { nil }, parent: parentLink)
                    link.track(TestEvents.Test, trackedProperties:  [])
                    
                    expect(receivedEventName).to(equal("TrackableTests.ChainerTests.TestEvents.Test"))
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.bool"] as? Bool).to(beTrue())
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.string"] as? String).to(equal("Hello"))
                }

                it("should track event when parent doesn't exist") {
                    let instanceProperties : Set<TrackedProperty> = [TestKeys.Tests.string ~>> "Hello", TestKeys.Tests.bool ~>> true]
                    let classProperties : Set<TrackedProperty> = [TestKeys.Tests.bool ~>> false]
                    
                    var receivedEventName: String?
                    var receivedProperties: [String: AnyObject]?
                    
                    trackEvent = { (eventName: String, trackedProperties: [String: AnyObject]) in
                        receivedEventName = eventName
                        receivedProperties = trackedProperties
                    }
                    
                    let link = ChainLink.Chainer(instanceProperties: instanceProperties, classProperties: { classProperties }, parent: nil)
                    link.track(TestEvents.Test, trackedProperties:  [])
                    
                    expect(receivedEventName).to(equal("TrackableTests.ChainerTests.TestEvents.Test"))
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.bool"] as? Bool).to(beTrue())
                    expect(receivedProperties?["TrackableTests.ChainerTests.TestKeys.Tests.string"] as? String).to(equal("Hello"))
                }
            }
            
            it("should delete ChainLinks for released objects") {
                class A : Trackable { }
                class B : Trackable { }
                class C : Trackable { }
                
                var identifierA : ObjectIdentifier?
                var identifierB : ObjectIdentifier?
                var identifierC : ObjectIdentifier?
                
                autoreleasepool {
                    let classA = A()
                    let classB = B()
                    let classC = C()
                    
                    classA.setupTrackableChain([], parent: classC)
                    classB.setupTrackableChain([], parent: classA)
                    
                    identifierA = ObjectIdentifier(classA)
                    identifierB = ObjectIdentifier(classB)
                    identifierC = ObjectIdentifier(classC)
                    
                    expect(ChainLink.responsibilityChainTable[identifierA!]).toNot(beNil())
                    expect(ChainLink.responsibilityChainTable[identifierB!]).toNot(beNil())
                    expect(ChainLink.responsibilityChainTable[identifierC!]).toNot(beNil())
                }
                
                ChainLink.cleanupResponsibilityChainTable()
                expect(ChainLink.responsibilityChainTable[identifierA!]).to(beNil())
                expect(ChainLink.responsibilityChainTable[identifierB!]).to(beNil())
                expect(ChainLink.responsibilityChainTable[identifierC!]).to(beNil())
            }

            
        }
    }
    
}