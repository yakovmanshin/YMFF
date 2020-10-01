//
//  FeatureFlagStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagStore

/// An object that provides a number of ways to supply the feature flag store.
public enum FeatureFlagStore {
    case opaque(FeatureFlagStoreProtocol)
    case transparent(TransparentFeatureFlagStore)
}

// MARK: - FeatureFlagStoreProtocol

extension FeatureFlagStore: FeatureFlagStoreProtocol {
    
    public func value(forKey key: String) -> Any? {
        switch self {
        case .opaque(let store):
            return store.value(forKey: key)
        case .transparent(let store):
            return store[key]
        }
    }
    
}
