//
//  FeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 4/10/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagStore

/// The enum used to configure the feature flag resolver.
public enum FeatureFlagStore {
    case immutable(FeatureFlagStoreProtocol)
    case mutable(MutableFeatureFlagStoreProtocol)
}

public extension FeatureFlagStore {
    
    /// Returns the underlying feature flag store as an immutable, regardless of its actual type.
    var asImmutable: FeatureFlagStoreProtocol {
        switch self {
        case .immutable(let store):
            return store
        case .mutable(let store):
            return store
        }
    }
    
    /// Returns the underlying feature flag store if it’s mutable; otherwise, `nil`.
    var asMutable: MutableFeatureFlagStoreProtocol? {
        switch self {
        case .immutable:
            return nil
        case .mutable(let store):
            return store
        }
    }
    
}
