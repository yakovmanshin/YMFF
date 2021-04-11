//
//  FeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 4/10/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

public enum FeatureFlagStore {
    case immutable(FeatureFlagStoreProtocol)
    case mutable(MutableFeatureFlagStoreProtocol)
}

public extension FeatureFlagStore {
    
    var asImmutable: FeatureFlagStoreProtocol {
        switch self {
        case .immutable(let store):
            return store
        case .mutable(let store):
            return store
        }
    }
    
}
