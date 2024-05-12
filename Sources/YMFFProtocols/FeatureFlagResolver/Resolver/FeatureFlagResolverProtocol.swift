//
//  FeatureFlagResolverProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// A service that resolves feature flag values with their keys.
public protocol FeatureFlagResolverProtocol {
    
    /// Returns a value for the specified key.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func value<Value>(for key: FeatureFlagKey) async throws -> Value
    
    /// Sets a new feature flag value to the first mutable store found in `configuration.stores`.
    ///
    /// - Parameters:
    ///   - newValue: *Required.* The override value.
    ///   - key: *Required.* The feature flag key.
    func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws
    
    /// Removes the value from the first mutable feature flag store which has one for the specified key.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func removeValue(for key: FeatureFlagKey) async throws
    
}
