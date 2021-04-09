//
//  FeatureFlagStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)
import Foundation
#endif

import YMFFProtocols

// MARK: - FeatureFlagStore

/// An object that provides a number of ways to supply the feature flag store.
public enum FeatureFlagStore {
    case opaque(FeatureFlagStoreProtocol)
    case transparent(TransparentFeatureFlagStore)
    
    #if canImport(Foundation)
    case userDefaults(UserDefaults)
    #endif
}

// MARK: - FeatureFlagStoreProtocol

extension FeatureFlagStore: FeatureFlagStoreProtocol {
    
    public func containsValue(forKey key: String) -> Bool {
        switch self {
        case .opaque(let store):
            return store.containsValue(forKey: key)
        case .transparent(let store):
            return store[key] != nil
        #if canImport(Foundation)
        case .userDefaults(let userDefaults):
            return userDefaults.object(forKey: key) != nil
        #endif
        }
    }
    
    public func value<Value>(forKey key: String) -> Value? {
        switch self {
        case .opaque(let store):
            return store.value(forKey: key)
        case .transparent(let store):
            return store[key] as? Value
        #if canImport(Foundation)
        case .userDefaults(let userDefaults):
            return userDefaults.object(forKey: key) as? Value
        #endif
        }
    }
    
}
