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

// MARK: - SynchronousMutableFeatureFlagStore

extension RuntimeOverridesStore: SynchronousMutableFeatureFlagStore {
    
    public func valueSync<Value>(forKey key: String) -> Result<Value, FeatureFlagStoreError> {
        guard let anyValue = store[key] else { return .failure(.valueNotFound) }
        guard let value = anyValue as? Value else { return .failure(.typeMismatch) }
        return .success(value)
    }
    
    public func setValueSync<Value>(_ value: Value, forKey key: String) {
        store[key] = value
    }
    
    public func removeValueSync(forKey key: String) {
        store.removeValue(forKey: key)
    }
    
}
