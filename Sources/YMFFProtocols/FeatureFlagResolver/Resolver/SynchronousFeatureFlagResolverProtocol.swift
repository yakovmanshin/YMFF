//
//  SynchronousFeatureFlagResolverProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 4/28/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousFeatureFlagResolverProtocol: FeatureFlagResolverProtocol {
    
    /// Returns a value for the specified key.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func valueSync<Value>(for key: FeatureFlagKey) throws -> Value
    
    /// Sets a new feature flag value to the first mutable store found in `configuration.stores`.
    ///
    /// - Parameters:
    ///   - newValue: *Required.* The override value.
    ///   - key: *Required.* The feature flag key.
    func setValueSync<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) throws
    
    /// Removes the value from the first mutable feature flag store which has one for the specified key.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func removeValueFromMutableStoreSync(using key: FeatureFlagKey) throws
    
}

// MARK: - Async Requirements

extension SynchronousFeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) async throws -> Value {
        try valueSync(for: key)
    }
    
    public func setValue<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) async throws {
        try setValueSync(newValue, toMutableStoreUsing: key)
    }
    
    public func removeValueFromMutableStore(using key: FeatureFlagKey) async throws {
        try removeValueFromMutableStoreSync(using: key)
    }
    
}
