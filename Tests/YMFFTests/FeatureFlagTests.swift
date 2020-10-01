//
//  FeatureFlagTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

// MARK: - Configuration

final class FeatureFlagTests: XCTestCase {
    
    private static let resolver: FeatureFlagResolverProtocol = FeatureFlagResolver(configuration: SharedAssets.configuration)
    
    @FeatureFlag(SharedAssets.boolKey.localKey, default: false, resolver: resolver)
    private var boolFeatureFlag
    
    @FeatureFlag(SharedAssets.intKey.localKey, default: 999, resolver: resolver)
    private var intFeatureFlag
    
    @FeatureFlag(SharedAssets.stringKey.localKey, default: "FALLBACK_STRING", resolver: resolver)
    private var stringFeatureFlag
    
    @FeatureFlag(SharedAssets.optionalIntNonNilKey.localKey, default: 999, resolver: resolver)
    private var optionalIntFeatureFlag
    
    @FeatureFlag(SharedAssets.nonexistentKey.localKey, default: 999, resolver: resolver)
    private var nonexistentIntFeatureFlag
    
    @FeatureFlag(SharedAssets.intToOverrideKey.remoteKey, default: 999, resolver: resolver)
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
    }
    
    func testNonexistentWrappedValueOverride() {
        XCTAssertEqual(nonexistentOverrideFlag, 999)
        
        nonexistentOverrideFlag = 789
        
        XCTAssertEqual(nonexistentOverrideFlag, 789)
    }
    
}