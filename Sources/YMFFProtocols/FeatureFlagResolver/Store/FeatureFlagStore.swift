//
//  FeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// The object which stores and provides feature-flag values.
public protocol FeatureFlagStore {
    
    /// Retrieves a feature-flag value by its key.
    ///
    /// - Parameter key: *Required.* The key that points to a feature-flag value in the store.
    func value<Value>(for key: FeatureFlagKey) async -> Result<Value, FeatureFlagStoreError>
    
}
