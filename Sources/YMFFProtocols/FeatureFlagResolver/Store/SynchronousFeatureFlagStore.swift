//
//  SynchronousFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousFeatureFlagStore: FeatureFlagStore {
    
    /// Retrieves a feature flag value by its key.
    ///
    /// - Parameter key: *Required.* The key that points to a feature flag value in the store.
    func valueSync<Value>(forKey key: String) -> Result<Value, FeatureFlagStoreError>
    
}

// MARK: - Async Requirements

extension SynchronousFeatureFlagStore {
    
    public func value<Value>(forKey key: String) async -> Result<Value, FeatureFlagStoreError> {
        valueSync(forKey: key)
    }
    
}
