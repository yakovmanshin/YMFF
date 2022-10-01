//
//  FeatureFlagTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - Configuration

final class FeatureFlagTests: XCTestCase {
    
    private static let resolver: FeatureFlagResolverProtocol = FeatureFlagResolver(configuration: SharedAssets.configuration)
    
    @FeatureFlag(SharedAssets.boolKey, default: false, resolver: resolver)
    private var boolFeatureFlag
    
    @FeatureFlag(SharedAssets.intKey, default: 999, resolver: resolver)
    private var intFeatureFlag
    
    @FeatureFlag(SharedAssets.stringKey, default: "FALLBACK_STRING", resolver: resolver)
    private var stringFeatureFlag
    
    @FeatureFlag(SharedAssets.optionalIntKey, default: 999 as Int?, resolver: resolver)
    private var optionalIntFeatureFlag
    
    @FeatureFlag(SharedAssets.nonexistentKey, default: 999, resolver: resolver)
    private var nonexistentIntFeatureFlag
    
    @FeatureFlag(SharedAssets.intToOverrideKey, default: 999, resolver: resolver)
    private var overrideFlag
    
    @FeatureFlag("NONEXISTENT_OVERRIDE_KEY", default: 999, resolver: resolver)
    private var nonexistentOverrideFlag
    
    @FeatureFlag(
        SharedAssets.stringToBoolKey,
        transformer: .init(valueFromRawValue: { $0 == "true" }, rawValueFromValue: { $0 ? "true" : "false" }),
        default: false,
        resolver: resolver
    )
    private var stringToBoolFeatureFlag
    
    @FeatureFlag(
        SharedAssets.stringToAdTypeKey,
        transformer: .init(valueFromRawValue: { AdType(rawValue: $0) }, rawValueFromValue: { $0.rawValue }),
        default: .none,
        resolver: resolver
    )
    private var stringToAdTypeFeatureFlag
    
}

// MARK: - Wrapped Value Tests

extension FeatureFlagTests {
    
    func testBoolWrappedValue() {
        XCTAssertTrue(boolFeatureFlag)
    }
    
    func testIntWrappedValue() {
        XCTAssertEqual(intFeatureFlag, 123)
    }
    
    func testStringWrappedValue() {
        XCTAssertEqual(stringFeatureFlag, "STRING_VALUE_REMOTE")
    }
    
    func testOptionalIntValue() {
        XCTAssertEqual(optionalIntFeatureFlag, 999)
    }
    
    func testNonexistentIntWrappedValue() {
        XCTAssertEqual(nonexistentIntFeatureFlag, 999)
    }
    
    func testWrappedValueOverride() {
        XCTAssertEqual(overrideFlag, 456)
        
        overrideFlag = 789
        
        XCTAssertEqual(overrideFlag, 789)
        
        $overrideFlag.removeValueFromMutableStore()
        
        XCTAssertEqual(overrideFlag, 456)
    }
    
    func testNonexistentWrappedValueOverride() {
        XCTAssertEqual(nonexistentOverrideFlag, 999)
        
        nonexistentOverrideFlag = 789
        
        XCTAssertEqual(nonexistentOverrideFlag, 789)
        
        $nonexistentOverrideFlag.removeValueFromMutableStore()
        
        XCTAssertEqual(nonexistentOverrideFlag, 999)
    }
    
    func testStringToBoolWrappedValue() {
        XCTAssertTrue(stringToBoolFeatureFlag)
    }
    
    func testStringToBoolWrappedValueOverride() {
        XCTAssertTrue(stringToBoolFeatureFlag)
        
        stringToBoolFeatureFlag = false
        XCTAssertFalse(stringToBoolFeatureFlag)
        
        $stringToBoolFeatureFlag.removeValueFromMutableStore()
        XCTAssertTrue(stringToBoolFeatureFlag)
    }
    
    func testStringToAdTypeWrappedValue() {
        XCTAssertEqual(stringToAdTypeFeatureFlag, .video)
    }
    
    func testStringToAdTypeWrappedValueOverride() {
        XCTAssertEqual(stringToAdTypeFeatureFlag, .video)
        
        stringToAdTypeFeatureFlag = .banner
        XCTAssertEqual(stringToAdTypeFeatureFlag, .banner)
        
        XCTAssertNoThrow(try Self.resolver.setValue("image", toMutableStoreUsing: SharedAssets.stringToAdTypeKey))
        XCTAssertEqual(stringToAdTypeFeatureFlag, .none)
        
        $stringToAdTypeFeatureFlag.removeValueFromMutableStore()
        XCTAssertEqual(stringToAdTypeFeatureFlag, .video)
    }
    
}

// MARK: - Projected Value Tests

extension FeatureFlagTests {
    
    func testBoolProjectedValue() {
        XCTAssertTrue(value($boolFeatureFlag, isOfType: IdentityFeatureFlag<Bool>.self))
    }
    
    func testIntProjectedValue() {
        XCTAssertTrue(value($intFeatureFlag, isOfType: IdentityFeatureFlag<Int>.self))
    }
    
    func testStringProjectedValue() {
        XCTAssertTrue(value($stringFeatureFlag, isOfType: IdentityFeatureFlag<String>.self))
    }
    
    func testOptionalIntProjectedValue() {
        XCTAssertTrue(value($optionalIntFeatureFlag, isOfType: IdentityFeatureFlag<Int?>.self))
    }
    
    func testNonexistentIntProjectedValue() {
        XCTAssertTrue(value($nonexistentIntFeatureFlag, isOfType: IdentityFeatureFlag<Int>.self))
    }
    
    func testStringToBoolProjectedValue() {
        XCTAssertTrue(value($stringToBoolFeatureFlag, isOfType: FeatureFlag<String, Bool>.self))
    }
    
    func testStringToAdTypeProjectedValue() {
        XCTAssertTrue(value($stringToAdTypeFeatureFlag, isOfType: FeatureFlag<String, AdType>.self))
    }
    
    private func value<T>(_ value: Any, isOfType type: T.Type) -> Bool {
        value is T
    }
    
}

// MARK: - Support Types

fileprivate typealias IdentityFeatureFlag<Value> = FeatureFlag<Value, Value>

fileprivate enum AdType: String {
    case none
    case banner
    case video
}
