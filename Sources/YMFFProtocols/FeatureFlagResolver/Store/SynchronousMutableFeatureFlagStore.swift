//
//  SynchronousMutableFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

/// The synchronous version of `MutableFeatureFlagStore`.
public protocol SynchronousMutableFeatureFlagStore: SynchronousFeatureFlagStore, MutableFeatureFlagStore {
    
    /// Synchronously adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to add.
    ///   - key: *Required.* The feature-flag key.
    func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) throws
    
    /// Synchronously removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValueSync(for key: FeatureFlagKey) throws
    
}

// MARK: - Async Requirements

extension SynchronousMutableFeatureFlagStore {
    
    public func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws {
        try setValueSync(value, for: key)
    }
    
    public func removeValue(for key: FeatureFlagKey) async throws {
        try removeValueSync(for: key)
    }
    
}
