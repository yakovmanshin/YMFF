//
//  SynchronousMutableFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousMutableFeatureFlagStore: SynchronousFeatureFlagStore, MutableFeatureFlagStore {
    
    /// Adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to record.
    ///   - key: *Required.* The key used to address the value.
    func setValueSync<Value>(_ value: Value, forKey key: String) throws
    
    /// Removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValueSync(forKey key: String) throws
    
    /// Immediately saves changed values so they’re not lost.
    ///
    /// + This method can be called when work with the feature flag store is finished.
    func saveChangesSync() throws
    
}

// MARK: - Async Requirements

extension SynchronousMutableFeatureFlagStore {
    
    public func setValue<Value>(_ value: Value, forKey key: String) async throws {
        try setValueSync(value, forKey: key)
    }
    
    public func removeValue(forKey key: String) async throws {
        try removeValueSync(forKey: key)
    }
    
    public func saveChanges() async throws {
        try saveChangesSync()
    }
    
}

// MARK: - Default Implementation

extension SynchronousMutableFeatureFlagStore {
    
    public func saveChangesSync() throws { }
    
}
