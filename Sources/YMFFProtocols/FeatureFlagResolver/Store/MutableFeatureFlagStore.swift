//
//  MutableFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// The object which stores and provides mutable feature-flag values.
public protocol MutableFeatureFlagStore: AnyObject, FeatureFlagStore {
    
    /// Adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to add.
    ///   - key: *Required.* The feature-flag key.
    func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws
    
    /// Removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValue(for key: FeatureFlagKey) async throws
    
}
