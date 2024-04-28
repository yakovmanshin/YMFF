//
//  UserDefaultsStoreTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 3/21/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)

@testable import YMFF

import XCTest

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
    
    func test_containsValue() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        let containsValue1 = await store.containsValue(forKey: "TEST_key1")
        let containsValue2 = await store.containsValue(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_containsValueSync() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        let containsValue1 = store.containsValueSync(forKey: "TEST_key1")
        let containsValue2 = store.containsValueSync(forKey: "TEST_key2")
        
        XCTAssertTrue(containsValue1)
        XCTAssertFalse(containsValue2)
    }
    
    func test_value() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        let value1: String? = await store.value(forKey: "TEST_key1")
        let value2: Int? = await store.value(forKey: "TEST_key2")
        let value3: Bool? = await store.value(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
    func test_valueSync() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        let value1: String? = store.valueSync(forKey: "TEST_key1")
        let value2: Int? = store.valueSync(forKey: "TEST_key2")
        let value3: Bool? = store.valueSync(forKey: "TEST_key3")
        
        XCTAssertEqual(value1, "TEST_value1")
        XCTAssertNil(value2)
        XCTAssertNil(value3)
    }
    
    func test_setValue() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        await store.setValue("TEST_newValue1", forKey: "TEST_key1")
        await store.setValue("TEST_newValue2", forKey: "TEST_key2")
        
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_newValue1")
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_newValue2")
    }
    
    func test_setValueSync() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        
        store.setValueSync("TEST_newValue1", forKey: "TEST_key1")
        store.setValueSync("TEST_newValue2", forKey: "TEST_key2")
        
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key1"), "TEST_newValue1")
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_newValue2")
    }
    
    func test_removeValue() async {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        await store.removeValue(forKey: "TEST_key1")
        await store.removeValue(forKey: "TEST_key999")
        
        XCTAssertNil(userDefaults.string(forKey: "TEST_key1"))
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        XCTAssertNil(userDefaults.string(forKey: "TEST_key999"))
    }
    
    func test_removeValueSync() {
        userDefaults.set("TEST_value1", forKey: "TEST_key1")
        userDefaults.set("TEST_value2", forKey: "TEST_key2")
        
        store.removeValueSync(forKey: "TEST_key1")
        store.removeValueSync(forKey: "TEST_key999")
        
        XCTAssertNil(userDefaults.string(forKey: "TEST_key1"))
        XCTAssertEqual(userDefaults.string(forKey: "TEST_key2"), "TEST_value2")
        XCTAssertNil(userDefaults.string(forKey: "TEST_key999"))
    }
    
}

#endif
