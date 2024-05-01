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
    
    func test_containsValue() async {
        store.store = ["TEST_key1": "TEST_value1"]
        
        let containsValue1 = await store.containsValue(forKey: "TEST_key1")
        let containsValue2 = await store.containsValue(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_containsValueSync() {
        store.store = ["TEST_key1": "TEST_value1"]
        
        let containsValue1 = store.containsValueSync(forKey: "TEST_key1")
        let containsValue2 = store.containsValueSync(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_value() async {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        let value1: String? = await store.value(forKey: "TEST_key1")
        let value2: Int? = await store.value(forKey: "TEST_key2")
        let value3: Bool? = await store.value(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
    func test_valueSync() {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        let value1: String? = store.valueSync(forKey: "TEST_key1")
        let value2: Int? = store.valueSync(forKey: "TEST_key2")
        let value3: Bool? = store.valueSync(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
    func test_setValue() async {
        store.store = ["TEST_key1": "TEST_value1"]
        
        await store.setValue("TEST_newValue1", forKey: "TEST_key1")
        await store.setValue("TEST_newValue2", forKey: "TEST_key2")
        
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
    
    func test_removeValue() async {
        store.store = [
            "TEST_key1": "TEST_value1",
            "TEST_key2": "TEST_value2",
        ]
        
        await store.removeValue(forKey: "TEST_key1")
        await store.removeValue(forKey: "TEST_key999")
        
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
