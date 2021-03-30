//
//  FeatureFlagTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
import YMFFProtocols
@testable import YMFF

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
        
        $overrideFlag.removeRuntimeOverride()
        
        XCTAssertEqual(overrideFlag, 456)
    }
    
    func testNonexistentWrappedValueOverride() {
        XCTAssertEqual(nonexistentOverrideFlag, 999)
        
        nonexistentOverrideFlag = 789
        
        XCTAssertEqual(nonexistentOverrideFlag, 789)
        
        $nonexistentOverrideFlag.removeRuntimeOverride()
        
        XCTAssertEqual(nonexistentOverrideFlag, 999)
    }
    
}

// MARK: - Projected Value Tests

extension FeatureFlagTests {
    
    func testBoolProjectedValue() {
        XCTAssertTrue(value($boolFeatureFlag, isOfType: FeatureFlag<Bool>.self))
    }
    
    func testIntProjectedValue() {
        XCTAssertTrue(value($intFeatureFlag, isOfType: FeatureFlag<Int>.self))
    }
    
    func testStringProjectedValue() {
        XCTAssertTrue(value($stringFeatureFlag, isOfType: FeatureFlag<String>.self))
    }
    
    func testOptionalIntProjectedValue() {
        XCTAssertTrue(value($optionalIntFeatureFlag, isOfType: FeatureFlag<Int?>.self))
    }
    
    func testNonexistentIntProjectedValue() {
        XCTAssertTrue(value($nonexistentIntFeatureFlag, isOfType: FeatureFlag<Int>.self))
    }
    
    private func value<T>(_ value: Any, isOfType type: T.Type) -> Bool {
        value is T
    }
    
}
