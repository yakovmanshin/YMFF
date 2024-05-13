//
//  SynchronousFeatureFlagResolverProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 4/28/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

/// The synchronous version of `FeatureFlagResolverProtocol`.
public protocol SynchronousFeatureFlagResolverProtocol: FeatureFlagResolverProtocol {
    
    /// Synchronously returns the value from the first *synchronous* feature-flag store which contains one.
    ///
    /// + Asynchronous feature-flag stores are ignored.
    ///
    /// - Parameter key: *Required.* The feature-flag key.
    func valueSync<Value>(for key: FeatureFlagKey) throws -> Value
    
    /// Synchronously sets the feature-flag value to all *synchronous* mutable stores.
    ///
    /// + Asynchronous feature-flag stores are ignored.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value.
    ///   - key: *Required.* The feature-flag key.
    func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) throws
    
    /// Synchronously removes the feature-flag value from all *synchronous* mutable stores.
    ///
    /// + Asynchronous feature-flag stores are ignored.
    ///
    /// - Parameter key: *Required.* The feature-flag key.
    func removeValueSync(for key: FeatureFlagKey) throws
    
}

// MARK: - Async Requirements

extension SynchronousFeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) async throws -> Value {
        try valueSync(for: key)
    }
    
    public func setValue<Value>(_ newValue: Value, for key: FeatureFlagKey) async throws {
        try setValueSync(newValue, for: key)
    }
    
    public func removeValue(for key: FeatureFlagKey) async throws {
        try removeValueSync(for: key)
    }
    
}
