//
//  TransparentFeatureFlagStoreTests.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 4/28/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

final class TransparentFeatureFlagStoreTests: XCTestCase {
    
    private var store: TransparentFeatureFlagStore!
    
    override func setUp() {
        super.setUp()
        
        store = [:]
    }
    
    func test_containsValue() async {
        store["TEST_key1"] = "TEST_value1"
        
        let containsValue1 = await store.containsValue(forKey: "TEST_key1")
        let containsValue2 = await store.containsValue(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_containsValueSync() {
        store["TEST_key1"] = "TEST_value1"
        
        let containsValue1 = store.containsValueSync(forKey: "TEST_key1")
        let containsValue2 = store.containsValueSync(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_value() async throws {
        store["TEST_key1"] = "TEST_value1"
        store["TEST_key2"] = "TEST_value2"
        
        let value1: String = try await store.value(forKey: "TEST_key1")
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try await store.value(forKey: "TEST_key2")
            XCTFail("Expected an error")
        } catch CommonFeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        do {
            let _: Bool = try await store.value(forKey: "TEST_key3")
            XCTFail("Expected an error")
        } catch CommonFeatureFlagStoreError.valueNotFound(key: let key) {
            XCTAssertEqual(key, "TEST_key3")
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func test_valueSync() throws {
        store["TEST_key1"] = "TEST_value1"
        store["TEST_key2"] = "TEST_value2"
        
        let value1: String = try store.valueSync(forKey: "TEST_key1")
        XCTAssertEqual(value1, "TEST_value1")
        
        do {
            let _: Int = try store.valueSync(forKey: "TEST_key2")
            XCTFail("Expected an error")
        } catch CommonFeatureFlagStoreError.typeMismatch { } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        do {
            let _: Bool = try store.valueSync(forKey: "TEST_key3")
            XCTFail("Expected an error")
        } catch CommonFeatureFlagStoreError.valueNotFound(key: let key) {
            XCTAssertEqual(key, "TEST_key3")
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
