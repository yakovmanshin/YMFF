//
//  FeatureFlagResolverProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// The object which resolves feature-flag values.
public protocol FeatureFlagResolverProtocol {
    
    /// Returns the value from the first feature-flag store which contains one.
    ///
    /// - Parameter key: *Required.* The feature-flag key.
    func value<Value>(for key: FeatureFlagKey) async throws -> Value
    
    /// Sets the feature-flag value to all mutable stores.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value.
    ///   - key: *Required.* The feature-flag key.
    func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws
    
    /// Removes the feature-flag value from all mutable stores.
    ///
    /// - Parameter key: *Required.* The feature-flag key.
    func removeValue(for key: FeatureFlagKey) async throws
    
}
