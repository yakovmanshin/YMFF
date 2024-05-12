//
//  MutableFeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that stores feature flag values that can be added and removed in runtime.
public protocol MutableFeatureFlagStore: AnyObject, FeatureFlagStore {
    
    /// Adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to record.
    ///   - key: *Required.* The key used to address the value.
    func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws
    
    /// Removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValue(for key: FeatureFlagKey) async throws
    
    /// Immediately saves changed values so they’re not lost.
    ///
    /// + This method can be called when work with the feature flag store is finished.
    func saveChanges() async throws
    
}

// MARK: - Default Implementation

extension MutableFeatureFlagStore {
    
    // Not all kinds of feature flag stores need this method, so it’s optional to implement.
    public func saveChanges() async throws { }
    
}
