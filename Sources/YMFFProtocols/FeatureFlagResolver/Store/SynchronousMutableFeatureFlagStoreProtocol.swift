//
//  SynchronousMutableFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousMutableFeatureFlagStoreProtocol: SynchronousFeatureFlagStoreProtocol, MutableFeatureFlagStoreProtocol {
    
    /// Adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to record.
    ///   - key: *Required.* The key used to address the value.
    func setValueSync<Value>(_ value: Value, forKey key: String)
    
    /// Removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValueSync(forKey key: String)
    
    /// Immediately saves changed values so they’re not lost.
    ///
    /// + This method can be called when work with the feature flag store is finished.
    func saveChangesSync()
    
}

// MARK: - Async Requirements

extension SynchronousMutableFeatureFlagStoreProtocol {
    
    public func setValue<Value>(_ value: Value, forKey key: String) async {
        setValueSync(value, forKey: key)
    }
    
    public func removeValue(forKey key: String) async {
        removeValueSync(forKey: key)
    }
    
    public func saveChanges() async {
        saveChangesSync()
    }
    
}

// MARK: - Default Implementation

extension SynchronousMutableFeatureFlagStoreProtocol {
    
    public func saveChangesSync() { }
    
}
