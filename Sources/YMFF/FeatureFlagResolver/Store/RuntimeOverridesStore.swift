//
//  RuntimeOverridesStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - RuntimeOverridesStore

/// A YMFF-supplied implementation of the object that stores feature flag values used in runtime.
final public class RuntimeOverridesStore {
    
    var store: TransparentFeatureFlagStore
    
    public init() {
        store = .init()
    }
    
}

// MARK: - SynchronousMutableFeatureFlagStoreProtocol

extension RuntimeOverridesStore: SynchronousMutableFeatureFlagStoreProtocol {
    
    public func containsValueSync(forKey key: String) -> Bool {
        store[key] != nil
    }
    
    public func valueSync<Value>(forKey key: String) -> Value? {
        store[key] as? Value
    }
    
    public func setValueSync<Value>(_ value: Value, forKey key: String) {
        store[key] = value
    }
    
    public func removeValueSync(forKey key: String) {
        store.removeValue(forKey: key)
    }
    
}
