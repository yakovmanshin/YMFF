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

final class FeatureFlagTests: XCTestCase {
    
    private var resolver: SynchronousFeatureFlagResolverMock!
    
    override func setUp() {
        super.setUp()
        
        resolver = SynchronousFeatureFlagResolverMock()
    }
    
    override func tearDown() {
        resolver = nil
        
        super.tearDown()
    }
    
    func test_wrappedValue_fromResolver() {
        @FeatureFlag("TEST_bool_key", default: false, resolver: resolver)
        var boolFeatureFlag
        
        resolver.valueSync_result = .success(true)
        
        let wrappedValue = boolFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 1)
        XCTAssertEqual(resolver.valueSync_keys, ["TEST_bool_key"])
        XCTAssertTrue(wrappedValue)
    }
    
    func test_wrappedValue_fallback() {
        @FeatureFlag("TEST_int_key", default: 123, resolver: resolver)
        var intFeatureFlag
        
        resolver.valueSync_result = .failure(SomeError())
        
        let wrappedValue = intFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 1)
        XCTAssertEqual(resolver.valueSync_keys, ["TEST_int_key"])
        XCTAssertEqual(wrappedValue, 123)
    }
    
    func test_wrappedValue_valueTransformation_success() {
        @FeatureFlag(
            "TEST_enum_key",
            transformer: FeatureFlagValueTransformer { rawValue in
                AdType(rawValue: rawValue)
            } rawValueFromValue: { value in
                value.rawValue
            },
            default: .none,
            resolver: resolver
        )
        var enumFeatureFlag
        
        resolver.valueSync_result = .success("video")
        
        let wrappedValue = enumFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 1)
        XCTAssertEqual(resolver.valueSync_keys, ["TEST_enum_key"])
        XCTAssertEqual(wrappedValue, .video)
    }
    
    func test_wrappedValue_valueTransformation_failure() {
        @FeatureFlag(
            "TEST_enum_key",
            transformer: FeatureFlagValueTransformer { rawValue in
                AdType(rawValue: rawValue)
            } rawValueFromValue: { value in
                value.rawValue
            },
            default: .none,
            resolver: resolver
        )
        var enumFeatureFlag
        
        resolver.valueSync_result = .success("unknown_value")
        
        let wrappedValue = enumFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 1)
        XCTAssertEqual(resolver.valueSync_keys, ["TEST_enum_key"])
        XCTAssertEqual(wrappedValue, .none)
    }
    
    func test_wrappedValueOverride_success() {
        @FeatureFlag("TEST_int_key", default: 123, resolver: resolver)
        var intFeatureFlag
        
        resolver.setValueSync_result = .success(())
        
        intFeatureFlag = 456
        
        XCTAssertEqual(resolver.setValueSync_invocationCount, 1)
        XCTAssertEqual(resolver.setValueSync_keyValuePairs.count, 1)
        XCTAssertEqual(resolver.setValueSync_keyValuePairs[0].0, "TEST_int_key")
        XCTAssertEqual(resolver.setValueSync_keyValuePairs[0].1 as? Int, 456)
    }
    
    func test_wrappedValueOverride_failure() {
        @FeatureFlag("TEST_int_key", default: 123, resolver: resolver)
        var intFeatureFlag
        
        resolver.setValueSync_result = .failure(SomeError())
        
        intFeatureFlag = 456
        
        XCTAssertEqual(resolver.setValueSync_invocationCount, 1)
        XCTAssertEqual(resolver.setValueSync_keyValuePairs.count, 1)
        XCTAssertEqual(resolver.setValueSync_keyValuePairs[0].0, "TEST_int_key")
        XCTAssertEqual(resolver.setValueSync_keyValuePairs[0].1 as? Int, 456)
    }
    
    func test_wrappedValueOverrideRemoval_success() {
        @FeatureFlag("TEST_string_key", default: "TEST_value1", resolver: resolver)
        var stringFeatureFlag
        
        resolver.removeValueFromMutableStoreSync_result = .success(())
        
        $stringFeatureFlag.removeValueFromMutableStore()
        
        XCTAssertEqual(resolver.removeValueFromMutableStoreSync_invocationCount, 1)
        XCTAssertEqual(resolver.removeValueFromMutableStoreSync_keys, ["TEST_string_key"])
    }
    
    func test_wrappedValueOverrideRemoval_failure() {
        @FeatureFlag("TEST_string_key", default: "TEST_value1", resolver: resolver)
        var stringFeatureFlag
        
        resolver.removeValueFromMutableStoreSync_result = .failure(SomeError())
        
        $stringFeatureFlag.removeValueFromMutableStore()
        
        XCTAssertEqual(resolver.removeValueFromMutableStoreSync_invocationCount, 1)
        XCTAssertEqual(resolver.removeValueFromMutableStoreSync_keys, ["TEST_string_key"])
    }
    
    func test_projectedValue_typeCheck_noTransformation() {
        @FeatureFlag("TEST_string_key", default: "TEST_string", resolver: resolver)
        var stringFeatureFlag
        
        let projectedValue: Any = $stringFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 0)
        XCTAssertTrue(resolver.valueSync_keys.isEmpty)
        XCTAssertTrue(projectedValue is FeatureFlag<String, String>)
        XCTAssertFalse(projectedValue is FeatureFlag<String, Int>)
        XCTAssertFalse(projectedValue is FeatureFlag<Int, Double>)
    }
    
    func test_projectedValue_typeCheck_customTransformation() {
        @FeatureFlag(
            "TEST_bool_key",
            transformer: FeatureFlagValueTransformer { boolString in
                boolString == "YES"
            } rawValueFromValue: { bool in
                bool ? "YES" : "NO"
            },
            default: false,
            resolver: resolver
        )
        var boolFeatureFlag
        
        let projectedValue: Any = $boolFeatureFlag
        
        XCTAssertEqual(resolver.valueSync_invocationCount, 0)
        XCTAssertTrue(resolver.valueSync_keys.isEmpty)
        XCTAssertTrue(projectedValue is FeatureFlag<String, Bool>)
        XCTAssertFalse(projectedValue is FeatureFlag<String, Int>)
        XCTAssertFalse(projectedValue is FeatureFlag<Int, Double>)
    }
    
}

// MARK: - Utilities

fileprivate enum AdType: String {
    case none
    case banner
    case video
}

fileprivate struct SomeError: Error { }
