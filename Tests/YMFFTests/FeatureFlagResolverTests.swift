//
//  FeatureFlagResolverTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/24/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

// MARK: - Configuration

final class FeatureFlagResolverTests: XCTestCase {
    
    private var resolver: FeatureFlagResolver!
    
    override func setUp() {
        super.setUp()
        
        resolver = FeatureFlagResolver(configuration: SharedAssets.configuration)
    }
    
}

// MARK: - Integrated Tests

extension FeatureFlagResolverTests {
    
    // MARK: Int Values
    
    func testIntValueResolution() {
        let expectedValue = 123
        
        XCTAssertEqual(resolver.value(for: SharedAssets.intKey), expectedValue)
        XCTAssertEqual(try resolveIntValue(for: SharedAssets.intKey), expectedValue)
    }
    
    private func resolveIntValue(for key: FeatureFlagKey) throws -> Int {
        try resolver._value(for: key)
    }
    
    // MARK: String Values
    
    func testStringValueResolution() {
        let expectedValue = "STRING_VALUE_REMOTE"
        
        XCTAssertEqual(resolver.value(for: SharedAssets.stringKey), expectedValue)
        XCTAssertEqual(try resolveStringValue(for: SharedAssets.stringKey), expectedValue)
    }
    
    private func resolveStringValue(for key: FeatureFlagKey) throws -> String {
        try resolver._value(for: key)
    }
    
    // MARK: Optional Values
    
    func testOptionalIntNilValueResolution() {
        let expectedValue: Int? = nil
        
        XCTAssertEqual(resolver.value(for: SharedAssets.optionalIntNilKey), expectedValue)
        do {
            _ = try resolveOptionalValue(for: SharedAssets.optionalIntNilKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    func testOptionalIntNonNilValueResolution() {
        let expectedValue: Int? = nil
        
        XCTAssertEqual(resolver.value(for: SharedAssets.optionalIntNonNilKey), expectedValue)
        do {
            _ = try resolveOptionalValue(for: SharedAssets.optionalIntNonNilKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    private func resolveOptionalValue(for key: FeatureFlagKey) throws -> Int? {
        try resolver._value(for: key)
    }
    
    // MARK: Nonexistent Values

    func testNonexistentValueResolution() throws {
        let expectedValue: Int? = nil
        
        XCTAssertEqual(resolver.value(for: SharedAssets.nonexistentKey), expectedValue)
        do {
            _ = try resolveNonexistentValue(for: SharedAssets.nonexistentKey)
            XCTFail()
        } catch FeatureFlagResolverError.noStoreContainsValueForKey { } catch { XCTFail() }
    }
    
    private func resolveNonexistentValue(for key: FeatureFlagKey) throws -> Int {
        try resolver._value(for: key)
    }
    
    // MARK: Value Type Casting
    
    func testValueTypeCasting() {
        do {
            _ = try resolveStringValue(for: SharedAssets.intKey)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
    }
    
    // MARK: Runtime Override
    
    func testRuntimeOverrideSuccess() {
        let key = SharedAssets.intKey
        let originalValue = 123
        let overrideValue = 789
        
        XCTAssertEqual(resolver.value(for: key), originalValue)
        
        XCTAssertNoThrow(try resolver.overrideInRuntime(key, with: overrideValue))
        
        XCTAssertEqual(resolver.value(for: key), overrideValue)
        
        resolver.removeRuntimeOverride(for: key)
        
        XCTAssertEqual(resolver.value(for: key), originalValue)
    }
    
    func testRuntimeOverrideFailure() {
        let key = SharedAssets.stringKey
        let overrideValue = 789
        
        XCTAssertEqual(resolver.value(for: key), "STRING_VALUE_REMOTE")
        
        do {
            _ = try resolver.overrideInRuntime(key, with: overrideValue)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
        
        XCTAssertEqual(resolver.value(for: key), "STRING_VALUE_REMOTE")
    }
    
    func testRuntimeOverrideForNewKeys() {
        let key = FeatureFlagKey("NEW_KEY")
        let overrideValue = 789
        
        XCTAssertNil(resolver.value(for: key))
        
        XCTAssertNoThrow(try resolver.overrideInRuntime(key, with: overrideValue))
        
        XCTAssertEqual(resolver.value(for: key), overrideValue)
    }
    
}

// MARK: - Units

extension FeatureFlagResolverTests {
    
    // MARK: Value Retrieval
    
    func testValueRetrieval() {
        let key = "int"
        
        XCTAssertNoThrow(try resolver.retrieveValueFromFirstStore(of: resolver.configuration.persistentStores, containingKey: key))
    }
    
    func testValueRetrievalFromEmptyPersistentStoresArray() {
        resolver = FeatureFlagResolver(configuration: SharedAssets.configurationWithNoPersistentStores)
        
        let key = "int"
        
        do {
            _ = try resolver.retrieveValueFromFirstStore(of: resolver.configuration.persistentStores, containingKey: key)
        } catch FeatureFlagResolverError.persistentStoresIsEmpty { } catch { XCTFail() }
    }
    
    // MARK: Value Validation
    
    func testValueValidation() {
        let nonOptionalValue = 123
        let optionalValue: Int? = 123
        
        XCTAssertNoThrow(try resolver.validateValue(nonOptionalValue))
        
        do {
            _ = try resolver.validateValue(optionalValue as Any)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    // MARK: Optionality Check
    
    func testIfValueIsOptional() {
        let nonOptionalValue = 123
        let optionalValue: Int? = 123
        
        XCTAssertFalse(resolver.valueIsOptional(nonOptionalValue))
        XCTAssertTrue(resolver.valueIsOptional(optionalValue as Any))
    }
    
    // MARK: Value Type Casting
    
    func testValueTypeCastingSuccess() {
        let int = 123
        let intAsAny = int as Any
        let targetType = Int.self
        
        XCTAssertEqual(try resolver.cast(intAsAny, to: targetType), int)
    }
    
    func testValueTypeCastingFailure() {
        let int = 123
        let intAsAny = int as Any
        let targetType = String.self
        
        do {
            _ = try resolver.cast(intAsAny, to: targetType)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
    }
    
    // MARK: Override Value Validation
    
    func testOverrideValueValidationSuccess() {
        let overrideValue = 789
        let intKey = SharedAssets.intKey
        
        XCTAssertNoThrow(try resolver.validateOverrideValue(overrideValue, forKey: intKey))
    }
    
    func testOverrideValueValidationFailureOptional() {
        let overrideValue = 789
        let stringKey = SharedAssets.stringKey
        
        do {
            try resolver.validateOverrideValue(overrideValue, forKey: stringKey)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
    }
    
    func testOverrideValueValidationFailureTypeMismatch() {
        let overrideValue: Int? = 789
        let stringKey = SharedAssets.intKey
        
        do {
            try resolver.validateOverrideValue(overrideValue, forKey: stringKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
}
