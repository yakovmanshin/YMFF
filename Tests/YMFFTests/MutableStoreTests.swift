//
//  MutableStoreTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 4/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
import YMFFProtocols

@testable import YMFF

// MARK: - MutableStoreTests

final class MutableStoreTests: XCTestCase {
    
    private var mutableStore: MutableFeatureFlagStoreProtocol!
    private var resolver: FeatureFlagResolverProtocol!
    
    override func setUp() {
        super.setUp()
        
        mutableStore = MutableFeatureFlagStore(store: .init())
        resolver = FeatureFlagResolver(configuration: .init(stores: [.mutable(mutableStore)]))
    }
    
    func testOverride() {
        let overrideKey = "OVERRIDE_KEY"
        let overrideValue = 123
        
        let initialValueFromResolver = try? resolver.value(for: overrideKey) as Int
        let initialValueFromStore: Int? = mutableStore.value(forKey: overrideKey)
        
        XCTAssertNil(initialValueFromResolver)
        XCTAssertNil(initialValueFromStore)
        
        try? resolver.overrideInRuntime(overrideKey, with: overrideValue)
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
        resolver = FeatureFlagResolver(configuration: .init(stores: [.mutable(mutableStore)]))
        
        resolver = nil
        
        XCTAssertEqual(saveChangesCount, 1)
    }
    
}

// MARK: - MutableFeatureFlagStore

final private class MutableFeatureFlagStore: MutableFeatureFlagStoreProtocol {
    
    private var store: TransparentFeatureFlagStore
    private var onSaveChangesClosure: () -> Void
    
    init(store: TransparentFeatureFlagStore, onSaveChanges: @escaping () -> Void = { }) {
        self.store = store
        self.onSaveChangesClosure = onSaveChanges
    }
    
    func containsValue(forKey key: String) -> Bool {
        store[key] != nil
    }
    
    func value<Value>(forKey key: String) -> Value? {
        let expectedValueType = Value.self
        
        switch expectedValueType {
        case is Bool.Type,
             is Int.Type,
             is String.Type,
             is Optional<Bool>.Type,
             is Optional<Int>.Type,
             is Optional<String>.Type:
            return store[key] as? Value
        default:
            assertionFailure("The expected feature flag value type (\(expectedValueType)) is not supported")
            return nil
        }
    }
    
    func setValue<Value>(_ value: Value, forKey key: String) {
        store[key] = value
    }
    
    func removeValue(forKey key: String) {
        store.removeValue(forKey: key)
    }
    
    func saveChanges() {
        onSaveChangesClosure()
    }
    
}
