//
//  RuntimeOverridesStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - RuntimeOverridesStore

/// A YMFF-supplied implementation of the object that stores feature flag values used in runtime.
final public class RuntimeOverridesStore {
    
    private var store: TransparentFeatureFlagStore
    
    public init() {
        store = .init()
    }
    
}

// MARK: - MutableFeatureFlagStoreProtocol

extension RuntimeOverridesStore: MutableFeatureFlagStoreProtocol {
    
    public func value<Value>(forKey key: String) -> Value? {
        store[key] as? Value
    }
    
    public func setValue<Value>(_ value: Value, forKey key: String) {
        store[key] = value
    }
    
    public func removeValue(forKey key: String) {
        store.removeValue(forKey: key)
    }
    
}
