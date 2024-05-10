//
//  RuntimeOverridesStoreTests.swift
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

final class RuntimeOverridesStoreTests: XCTestCase {
    
    private var store: RuntimeOverridesStore!
    
    override func setUp() {
        super.setUp()
        
        store = RuntimeOverridesStore()
    }
    
    func test_value() async throws {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        let value1: String = try await store.value(forKey: "TEST_key1").get()
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try await store.value(forKey: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let _: Bool = try await store.value(forKey: "TEST_key3").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.valueNotFound { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync() throws {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        let value1: String = try store.valueSync(forKey: "TEST_key1").get()
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try store.valueSync(forKey: "TEST_key2").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        do {
            let _: Bool = try store.valueSync(forKey: "TEST_key3").get()
            XCTFail("Expected an error")
        } catch FeatureFlagStoreError.valueNotFound { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue() async throws {
        store.store = ["TEST_key1": "TEST_value1"]
        
        try await store.setValue("TEST_newValue1", forKey: "TEST_key1")
        try await store.setValue("TEST_newValue2", forKey: "TEST_key2")
        
        XCTAssertEqual(store.store["TEST_key1"] as? String, "TEST_newValue1")
        XCTAssertEqual(store.store["TEST_key2"] as? String, "TEST_newValue2")
    }
    
    func test_setValueSync() {
        store.store = ["TEST_key1": "TEST_value1"]
        
        store.setValueSync("TEST_newValue1", forKey: "TEST_key1")
        store.setValueSync("TEST_newValue2", forKey: "TEST_key2")
        
        XCTAssertEqual(store.store["TEST_key1"] as? String, "TEST_newValue1")
        XCTAssertEqual(store.store["TEST_key2"] as? String, "TEST_newValue2")
    }
    
    func test_removeValue() async throws {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        try await store.removeValue(forKey: "TEST_key1")
        try await store.removeValue(forKey: "TEST_key999")
        
        XCTAssertNil(store.store["TEST_key1"])
        XCTAssertEqual(store.store["TEST_key2"] as? String, "TEST_value2")
        XCTAssertNil(store.store["TEST_key999"])
    }
    
    func test_removeValueSync() {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        store.removeValueSync(forKey: "TEST_key1")
        store.removeValueSync(forKey: "TEST_key999")
        
        XCTAssertNil(store.store["TEST_key1"])
        XCTAssertEqual(store.store["TEST_key2"] as? String, "TEST_value2")
        XCTAssertNil(store.store["TEST_key999"])
    }
    
}
