//
//  MutableStoreTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 4/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

@testable import YMFF

final class MutableStoreTests: XCTestCase {
    
    private var mutableStore: MutableFeatureFlagStoreProtocol!
    private var resolver: FeatureFlagResolverProtocol!
    
    override func setUp() {
        super.setUp()
        
        mutableStore = MutableFeatureFlagStore(store: .init())
        resolver = FeatureFlagResolver(stores: [.mutable(mutableStore)])
    }
    
    func testOverride() {
        let overrideKey = "OVERRIDE_KEY"
        let overrideValue = 123
        
        let initialValueFromResolver = try? resolver.value(for: overrideKey) as Int
        let initialValueFromStore: Int? = mutableStore.value(forKey: overrideKey)
        
        XCTAssertNil(initialValueFromResolver)
        XCTAssertNil(initialValueFromStore)
        
        try? resolver.setValue(overrideValue, toMutableStoreUsing: overrideKey)
        let overrideValueFromResolver = try? resolver.value(for: overrideKey) as Int
        let overrideValueFromStore: Int? = mutableStore.value(forKey: overrideKey)
        
        XCTAssertEqual(overrideValueFromResolver, overrideValue)
        XCTAssertEqual(overrideValueFromStore, overrideValue)
    }
    
    func testOverrideRemoval() {
        let overrideKey = "OVERRIDE_KEY"
        let overrideValue = 123
        
        mutableStore.setValue(overrideValue, forKey: overrideKey)
        
        let overrideValueFromResolver = try? resolver.value(for: overrideKey) as Int
        let overrideValueFromStore: Int? = mutableStore.value(forKey: overrideKey)
        
        XCTAssertEqual(overrideValueFromResolver, overrideValue)
        XCTAssertEqual(overrideValueFromStore, overrideValue)
        
        XCTAssertNoThrow(try resolver.removeValueFromMutableStore(using: overrideKey))
        
        let removedValueFromResolver = try? resolver.value(for: overrideKey) as Int
        let removedValueFromStore: Int? = mutableStore.value(forKey: overrideKey)
        
        XCTAssertNil(removedValueFromResolver)
        XCTAssertNil(removedValueFromStore)
    }
    
    func testChangeSaving() {
        var saveChangesCount = 0
        
        mutableStore = MutableFeatureFlagStore(store: .init()) {
            saveChangesCount += 1
        }
        resolver = FeatureFlagResolver(stores: [.mutable(mutableStore)])
        
        resolver = nil
        
        XCTAssertEqual(saveChangesCount, 1)
    }
    
}
