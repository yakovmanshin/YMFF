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
        
        XCTAssertEqual(try resolver.value(for: SharedAssets.intKey), expectedValue)
    }
    
    // MARK: String Values
    
    func testStringValueResolution() {
        let expectedValue = "STRING_VALUE_REMOTE"
        
        XCTAssertEqual(try resolver.value(for: SharedAssets.stringKey), expectedValue)
    }
    
    // MARK: Optional Values
    
    func testOptionalIntValueResolution() {
        do {
            let _: Int? = try resolver.value(for: SharedAssets.optionalIntKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    // MARK: Nonexistent Values

    func testNonexistentValueResolution() throws {
        do {
            let _: Int = try resolver.value(for: SharedAssets.nonexistentKey)
            XCTFail()
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores { } catch { XCTFail() }
    }
    
    // MARK: Runtime Override
    
    func testRuntimeOverrideSuccess() {
        let key = SharedAssets.intKey
        let originalValue = 123
        let overrideValue = 789
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
        
        XCTAssertNoThrow(try resolver.overrideInRuntime(key, with: overrideValue))
        
        XCTAssertEqual(try resolver.value(for: key), overrideValue)
        
        resolver.removeRuntimeOverride(for: key)
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
    }
    
    func testRuntimeOverrideFailure() {
        let key = SharedAssets.stringKey
        let overrideValue = 789
        
        XCTAssertEqual(try resolver.value(for: key), "STRING_VALUE_REMOTE")
        
        do {
            _ = try resolver.overrideInRuntime(key, with: overrideValue)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
        
        XCTAssertEqual(try resolver.value(for: key), "STRING_VALUE_REMOTE")
    }
    
    func testRuntimeOverrideForNewKeys() {
        let key = FeatureFlagKey("NEW_KEY")
        let overrideValue = 789
        
        do {
            let _: Int = try resolver.value(for: key)
            XCTFail()
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores { } catch { XCTFail() }
        
        XCTAssertNoThrow(try resolver.overrideInRuntime(key, with: overrideValue))
        
        XCTAssertEqual(try resolver.value(for: key), overrideValue)
    }
    
}

// MARK: - Units

extension FeatureFlagResolverTests {
    
    // MARK: Value Retrieval
    
    func testValueRetrieval() {
        let key = "int"
        
        XCTAssertNoThrow(try resolver.retrieveFirstValueFoundInPersistentStores(byKey: key) as Int)
    }
    
    func testValueRetrievalFromEmptyPersistentStoresArray() {
        resolver = FeatureFlagResolver(configuration: SharedAssets.configurationWithNoPersistentStores)
        
        let key = "int"
        
        do {
            let _: Int = try resolver.retrieveFirstValueFoundInPersistentStores(byKey: key)
        } catch FeatureFlagResolverError.noPersistentStoreAvailable { } catch { XCTFail() }
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
