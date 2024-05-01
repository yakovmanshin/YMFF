//
//  TransparentFeatureFlagStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - TransparentFeatureFlagStore

/// A simple dictionary used to store and retrieve feature flag values.
public typealias TransparentFeatureFlagStore = [String: Any]

// MARK: - SynchronousFeatureFlagStoreProtocol

extension TransparentFeatureFlagStore: SynchronousFeatureFlagStoreProtocol, FeatureFlagStoreProtocol {
    
    public func containsValueSync(forKey key: String) -> Bool {
        self[key] != nil
    }
    
    public func valueSync<V>(forKey key: String) -> V? {
        self[key] as? V
    }
    
}
