//
//  SynchronousFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

/// The synchronous version of `FeatureFlagStore`.
public protocol SynchronousFeatureFlagStore: FeatureFlagStore {
    
    /// Synchronously retrieves a feature-flag value by its key.
    ///
    /// - Parameter key: *Required.* The key that points to a feature-flag value in the store.
    func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError>
    
}

// MARK: - Async Requirements

extension SynchronousFeatureFlagStore {
    
    public func value<Value>(for key: FeatureFlagKey) async -> Result<Value, FeatureFlagStoreError> {
        valueSync(for: key)
    }
    
}
