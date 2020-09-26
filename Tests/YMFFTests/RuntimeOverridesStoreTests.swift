//
//  RuntimeOverridesStoreTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

// MARK: - Configuration

final class RuntimeOverridesStoreTests: XCTestCase {
    
    private var mutableStore: MutableFeatureFlagStoreProtocol!
    
    override func setUp() {
        super.setUp()
        
        mutableStore = RuntimeOverridesStore()
    }
    
}

// MARK: - Runtime Override Tests

extension RuntimeOverridesStoreTests {
    
    func testRuntimeOverride() {
        let overrideKey = "OVERRIDE_KEY"
        let overrideValue = 123
        
        mutableStore.setValue(overrideValue, forKey: overrideKey)
        let retrievedOverrideValue = mutableStore.value(forKey: overrideKey)
        
        XCTAssertNotNil(retrievedOverrideValue)
        XCTAssertEqual(retrievedOverrideValue as? Int, overrideValue)
    }
    
    func testRuntimeOverrideRemoval() {
        let overrideKey = "OVERRIDE_KEY"
        let overrideValue = 123
        
        mutableStore.setValue(overrideValue, forKey: overrideKey)
        let retrievedOverrideValue = mutableStore.value(forKey: overrideKey)
        
        XCTAssertNotNil(retrievedOverrideValue)
        
        mutableStore.removeValue(forKey: overrideKey)
        
        XCTAssertNil(mutableStore.value(forKey: overrideKey))
    }
    
}
