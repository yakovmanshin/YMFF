//
//  FeatureFlagResolverProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// A service that resolves feature flag values with their keys.
public protocol FeatureFlagResolverProtocol {
    
    /// The object used to configure the resolver.
    var configuration: FeatureFlagResolverConfigurationProtocol { get }
    
    /// Returns a value for the specified key.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func value<Value>(for key: FeatureFlagKey) throws -> Value
    
    /// Sets a new feature flag value that's available in runtime, within a single app session, and takes precedence over values from other stores.
    ///
    /// - Parameters:
    ///   - key: *Required.* The feature flag key.
    ///   - newValue: *Required.* The override value.
    func overrideInRuntime<Value>(_ key: FeatureFlagKey, with newValue: Value) throws
    
    /// Removes an override value for the specified key, and reverts to the default resolution scheme.
    ///
    /// - Parameter key: *Required.* The feature flag key.
    func removeRuntimeOverride(for key: FeatureFlagKey)
    
}
