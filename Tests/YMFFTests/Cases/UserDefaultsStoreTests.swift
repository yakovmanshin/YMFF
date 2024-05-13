//
//  UserDefaultsStoreTests.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 3/21/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

final class UserDefaultsStoreTests: XCTestCase {
    
    private var store: UserDefaultsStore!
    
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults()
        store = UserDefaultsStore(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults
            .dictionaryRepresentation()
            .keys
            .forEach(userDefaults.removeObject(forKey:))
        
        super.tearDown()
    }
    
    func test_value() async throws {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        let value1: String = try await store.value(for: "TEST_key1").get()
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try await store.value(for: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        do {
            let _: Bool = try await store.value(for: "TEST_key3").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.valueNotFound { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func test_valueSync() throws {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        let value1: String = try store.valueSync(for: "TEST_key1").get()
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try store.valueSync(for: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        do {
            let _: Bool = try store.valueSync(for: "TEST_key3").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.valueNotFound { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func test_value_optionals() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        // No record for TEST_key2
        
        do {
            let _: String? = try await store.value(for: "TEST_key1").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) { 
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let _: String? = try await store.value(for: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) { 
            XCTAssertNil(userDefaults.string(forKey: "TEST_key2"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_optionals() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        // No record for TEST_key2
        
        do {
            let _: String? = try store.valueSync(for: "TEST_key1").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) { 
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let _: String? = try store.valueSync(for: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) { 
            XCTAssertNil(userDefaults.string(forKey: "TEST_key2"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue() async throws {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        try await store.setValue("TEST_newValue1", for: "TEST_key1")
        try await store.setValue("TEST_newValue2", for: "TEST_key2")
        
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_newValue1")
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_newValue2")
    }
    
    func test_setValueSync() throws {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        try store.setValueSync("TEST_newValue1", for: "TEST_key1")
        try store.setValueSync("TEST_newValue2", for: "TEST_key2")
        
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_newValue1")
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_newValue2")
    }
    
    func test_setValue_optionals() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        do {
            let optionalValue1: String? = "TEST_newValue1"
            try await store.setValue(optionalValue1, for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) {
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let optionalValue2: String? = nil
            try await store.setValue(optionalValue2, for: "TEST_key2")
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) {
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_optionals() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        do {
            let optionalValue1: String? = "TEST_newValue1"
            try store.setValueSync(optionalValue1, for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) {
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let optionalValue2: String? = nil
            try store.setValueSync(optionalValue2, for: "TEST_key2")
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.otherError(UserDefaultsStore.Error.optionalValuesAreNotSupported) {
            XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValue() async throws {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        try await store.removeValue(for: "TEST_key1")
        try await store.removeValue(for: "TEST_key999")
        
        XCTAssertNil(userDefaults.string(forKey: "TEST_key1"))
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        XCTAssertNil(userDefaults.string(forKey: "TEST_key999"))
    }
    
    func test_removeValueSync() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        store.removeValueSync(for: "TEST_key1")
        store.removeValueSync(for: "TEST_key999")
        
        XCTAssertNil(userDefaults.string(forKey: "TEST_key1"))
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        XCTAssertNil(userDefaults.string(forKey: "TEST_key999"))
    }
    
}

#endif
