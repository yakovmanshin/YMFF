//
//  SynchronousFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousFeatureFlagStore: FeatureFlagStore {
    
    /// Indicates whether the store contains a value that corresponds to the key.
    ///
    /// - Parameter key: *Required.* The key.
    func containsValueSync(forKey key: String) -> Bool
    
    /// Retrieves a feature flag value by its key.
    ///
    /// - Parameter key: *Required.* The key that points to a feature flag value in the store.
    func valueSync<Value>(forKey key: String) throws -> Value
    
}

// MARK: - Async Requirements

extension SynchronousFeatureFlagStore {
    
    public func containsValue(forKey key: String) async -> Bool {
        containsValueSync(forKey: key)
    }
    
    public func value<Value>(forKey key: String) async throws -> Value {
        try valueSync(forKey: key)
    }
    
}
