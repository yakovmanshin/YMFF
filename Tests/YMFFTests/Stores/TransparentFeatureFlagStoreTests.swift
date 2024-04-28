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
    
    func test_value() async {
        store["TEST_key1"] = "TEST_value1"
        store["TEST_key2"] = "TEST_value2"
        
        let value1: String? = await store.value(forKey: "TEST_key1")
        let value2: Int? = await store.value(forKey: "TEST_key2")
        let value3: Bool? = await store.value(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
    func test_valueSync() {
        store["TEST_key1"] = "TEST_value1"
        store["TEST_key2"] = "TEST_value2"
        
        let value1: String? = store.valueSync(forKey: "TEST_key1")
        let value2: Int? = store.valueSync(forKey: "TEST_key2")
        let value3: Bool? = store.valueSync(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
}
