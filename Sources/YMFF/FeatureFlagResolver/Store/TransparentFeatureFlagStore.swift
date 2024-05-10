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

// MARK: - SynchronousFeatureFlagStore

extension TransparentFeatureFlagStore: SynchronousFeatureFlagStore, FeatureFlagStore {
    
    public func valueSync<V>(forKey key: String) -> Result<V, FeatureFlagStoreError> {
        guard let anyValue = self[key] else { return .failure(.valueNotFound) }
        guard let value = anyValue as? V else { return .failure(.typeMismatch) }
        return .success(value)
    }
    
}
