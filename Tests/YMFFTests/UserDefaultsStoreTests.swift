//
//  UserDefaultsStoreTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 3/21/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

final class UserDefaultsStoreTests: XCTestCase {
    
    private var resolver: FeatureFlagResolver!
    
    private lazy var userDefaults = UserDefaults()
    
    override func setUp() {
        super.setUp()
        
        resolver = FeatureFlagResolver(configuration: .init(stores: [
            .mutable(UserDefaultsStore(userDefaults: userDefaults))
        ]))
    }
    
}

extension UserDefaultsStoreTests {
    
    func testReadValueWithResolver() {
        let key = "TEST_UserDefaults_key_123"
        let value = 123
        
        userDefaults.setValue(value, forKey: key)
        
        // FIXME: [#40] Can't use `retrievedValue: Int?` here
        let retrievedValue = try? resolver.value(for: key) as Int
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testWriteValueWithResolver() {
        let key = "TEST_UserDefaults_key_456"
        let value = 456
        
        try? resolver.overrideInRuntime(key, with: value)
        
        let retrievedValue = userDefaults.value(forKey: key) as? Int
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testWriteAndReadValueWithResolver() {
        let key = "TEST_UserDefaults_key_789"
        let value = 789
        
        try? resolver.overrideInRuntime(key, with: value)
        
        // FIXME: [#40] Can't use `retrievedValue: Int?` here
        let retrievedValue = try? resolver.value(for: key) as Int
        
        XCTAssertEqual(retrievedValue, value)
    }
    
}
