//
//  FeatureFlagResolverTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/24/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

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
    
    // MARK: Overriding
    
    func testOverrideSuccess() {
        let key = SharedAssets.intKey
        let originalValue = 123
        let overrideValue = 789
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
        
        XCTAssertNoThrow(try resolver.setValue(overrideValue, toMutableStoreUsing: key))
        
        XCTAssertEqual(try resolver.value(for: key), overrideValue)
        
        XCTAssertNoThrow(try resolver.removeValueFromMutableStore(using: key))
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
    }
    
    func testOverrideFailureNoMutableStores() {
        resolver = FeatureFlagResolver(configuration: SharedAssets.configurationWithNoMutableStores)
        let key = SharedAssets.intKey
        let originalValue = 123
        let overrideValue = 789
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
        
        do {
            _ = try resolver.setValue(overrideValue, toMutableStoreUsing: key)
            XCTFail()
        } catch FeatureFlagResolverError.noMutableStoreAvailable { } catch { XCTFail() }
        
        XCTAssertEqual(try resolver.value(for: key), originalValue)
    }
    
    func testOverrideFailureTypeMismatch() {
        let key = SharedAssets.stringKey
        let overrideValue = 789
        
        XCTAssertEqual(try resolver.value(for: key), "STRING_VALUE_REMOTE")
        
        do {
            _ = try resolver.setValue(overrideValue, toMutableStoreUsing: key)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
        
        XCTAssertEqual(try resolver.value(for: key), "STRING_VALUE_REMOTE")
    }
    
    func testOverrideForNewKeys() {
        let key = FeatureFlagKey("NEW_KEY")
        let overrideValue = 789
        
        do {
            let _: Int = try resolver.value(for: key)
            XCTFail()
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores { } catch { XCTFail() }
        
        XCTAssertNoThrow(try resolver.setValue(overrideValue, toMutableStoreUsing: key))
        
        XCTAssertEqual(try resolver.value(for: key), overrideValue)
    }
    
    func testOverrideRemovalFailureNoMutableStoreContainsValue() {
        let key = FeatureFlagKey("KEY_WITH_NO_VALUE_IN_MUTABLE_STORES")
        
        do {
            try resolver.removeValueFromMutableStore(using: key)
            XCTFail()
        } catch FeatureFlagResolverError.noMutableStoreContainsValueForKey(key: let errorKey) {
            XCTAssertEqual(errorKey, key)
        } catch { XCTFail() }
    }
    
}

// MARK: - Units

extension FeatureFlagResolverTests {
    
    // MARK: Value Retrieval
    
    func testValueRetrieval() {
        let key = "int"
        
        XCTAssertNoThrow(try resolver.retrieveFirstValueFoundInStores(byKey: key) as Int)
    }
    
    func testValueRetrievalFromEmptyStoresArray() {
        resolver = FeatureFlagResolver(configuration: SharedAssets.configurationWithNoStores)
        
        let key = "int"
        
        do {
            let _: Int = try resolver.retrieveFirstValueFoundInStores(byKey: key)
        } catch FeatureFlagResolverError.noStoreAvailable { } catch { XCTFail() }
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
