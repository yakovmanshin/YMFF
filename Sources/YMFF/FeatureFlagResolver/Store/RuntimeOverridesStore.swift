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

/// A YMFF-supplied implementation of an object which stores feature-flag values with no persistence.
final public class RuntimeOverridesStore {
    
    var store: TransparentFeatureFlagStore
    
    public init() {
        store = .init()
    }
    
}

// MARK: - SynchronousMutableFeatureFlagStore

extension RuntimeOverridesStore: SynchronousMutableFeatureFlagStore {
    
    public func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError> {
        guard let anyValue = store[key] else { return .failure(.valueNotFound) }
        guard let value = anyValue as? Value else { return .failure(.typeMismatch) }
        return .success(value)
    }
    
    public func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) {
        store[key] = value
    }
    
    public func removeValueSync(for key: FeatureFlagKey) {
        store.removeValue(forKey: key)
    }
    
}
