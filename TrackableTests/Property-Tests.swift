//
//  Property-Tests.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation
@testable import Trackable
import Quick
import Nimble

class PropertyTests: QuickSpec {

    enum TestKeys: String, Key {
        case value1
        case value2
        case value3
        case value4
        
        enum Details: String, Key {
            case detail1
            case detail2
        }
    }

    override func spec() {
        beforeEach {
            keyPrefixToRemove = nil
            eventPrefixToRemove = nil
        }
        
        describe("Set of properties") {
            describe("updateValueFrom") {
                it("should add new value") {
                    var testSet = Set<TrackedProperty>([TestKeys.value1 ~>> "value1old", TestKeys.value2 ~>> "value2old"])
                    let newValue = TestKeys.value3 ~>> "value3new"
                    
                    testSet.updateValuesFrom(Set<TrackedProperty>([newValue]))
                    
                    expect(testSet.count) == 3
                    expect(testSet.filter { $0.key == TestKeys.value1.description }).toNot(beEmpty())
                    expect(testSet.filter { $0.key == TestKeys.value2.description }).toNot(beEmpty())
                    expect(testSet.filter { $0.key == TestKeys.value3.description }).toNot(beEmpty())
                    testSet.forEach {
                        switch $0.key {
                        case TestKeys.value1.description:
                            expect( $0.value as? String) == "value1old"
                        case TestKeys.value2.description:
                            expect($0.value as? String) == "value2old"
                        case TestKeys.value3.description:
                            expect($0.value as? String) == "value3new"
                        default:
                            fail()
                        }
                    }
                }

                it("should update existing value") {
                    var testSet = Set<TrackedProperty>([TestKeys.value1 ~>> "value1old", TestKeys.value2 ~>> "value2old"])
                    let newValue = TestKeys.value2 ~>> "value2new"
                    
                    testSet.updateValuesFrom(Set<TrackedProperty>([newValue]))
                    
                    expect(testSet.count) == 2
                    expect(testSet.filter { $0.key == TestKeys.value1.description }).toNot(beEmpty())
                    expect(testSet.filter { $0.key == TestKeys.value2.description }).toNot(beEmpty())
                    expect(testSet.filter { $0.key == TestKeys.value3.description }).to(beEmpty())
                    testSet.forEach {
                        switch $0.key {
                        case TestKeys.value1.description:
                            expect( $0.value as? String) == "value1old"
                        case TestKeys.value2.description:
                            expect($0.value as? String) == "value2new"
                        default:
                            fail()
                        }
                    }
                }
            }
            
            it("should init with String") {
                let testPropery = TestKeys.value1 ~>> "TestString"
                expect(testPropery.value as? String) == "TestString"
            }

            it("should init with Int") {
                let testPropery = TestKeys.value1 ~>> 5
                expect(testPropery.value as? Int) == 5
            }

            it("should init with Double") {
                let testPropery = TestKeys.value1 ~>> 5.63
                expect(testPropery.value as? Double) == 5.63
            }

            it("should init with Bool") {
                let testPropery = TestKeys.value1 ~>> true
                expect(testPropery.value as? Bool) == true
            }
            
            it("should init with Set of properties") {
                let value: Set<TrackedProperty> = [TestKeys.Details.detail1 ~>> "detail1"]
                let testProperty = TestKeys.value1 ~>> value
                let testValue = testProperty.value as! Set<TrackedProperty>
                testValue.forEach {
                    switch $0.key {
                    case "TrackableTests.PropertyTests.TestKeys.Details.detail1":
                        expect($0.value as? String) == "detail1"
                    default:
                        fail()
                    }
                }
            }

            it("should convert self to dictionary") {
                let testProperties: Set<TrackedProperty>= [
                    TestKeys.value1 ~>> true,
                    TestKeys.value2 ~>> "STP",
                    TestKeys.value3 ~>> 5.66,
                    TestKeys.value4 ~>> [TestKeys.Details.detail2 ~>> "detail"]
                ]
                
                let dictionary = testProperties.dictionaryRepresentation
                expect(dictionary["TrackableTests.PropertyTests.TestKeys.value1"] as? Bool).to(beTrue())
                expect(dictionary["TrackableTests.PropertyTests.TestKeys.value2"] as? String) == "STP"
                expect(dictionary["TrackableTests.PropertyTests.TestKeys.value3"] as? Double) == 5.66
                expect(dictionary["TrackableTests.PropertyTests.TestKeys.value4.Details.detail2"] as? String) == "detail"
            }
        }
        
        it("should properly implement + for sets") {
            let set1: Set<TrackedProperty> = [
                TestKeys.value1 ~>> true,
                TestKeys.value2 ~>> "STP",
            ]
            
            let set2: Set<TrackedProperty> = [
                TestKeys.value3 ~>> 5.66,
                TestKeys.value4 ~>> [TestKeys.Details.detail2 ~>> "detail"]
            ]
            
            let dictionary = (set1 + set2).dictionaryRepresentation
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value1"] as? Bool).to(beTrue())
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value2"] as? String) == "STP"
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value3"] as? Double) == 5.66
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value4.Details.detail2"] as? String) == "detail"
        }
        
        it("should properly implement += for sets") {
            var set1: Set<TrackedProperty> = [
                TestKeys.value1 ~>> true,
                TestKeys.value2 ~>> "STP",
            ]
            
            let set2: Set<TrackedProperty> = [
                TestKeys.value3 ~>> 5.66,
                TestKeys.value4 ~>> [TestKeys.Details.detail2 ~>> "detail"]
            ]
            
            set1 += set2
            let dictionary = (set1).dictionaryRepresentation
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value1"] as? Bool).to(beTrue())
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value2"] as? String) == "STP"
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value3"] as? Double) == 5.66
            expect(dictionary["TrackableTests.PropertyTests.TestKeys.value4.Details.detail2"] as? String) == "detail"
        }
    }
}
