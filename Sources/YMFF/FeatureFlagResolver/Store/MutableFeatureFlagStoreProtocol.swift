//
//  MutableFeatureFlagStoreProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that stores feature flag values that can be added and removed in runtime.
public protocol MutableFeatureFlagStoreProtocol: AnyObject, FeatureFlagStoreProtocol {
    
    /// Adds the value to the store so it can be retrieved with the key later.
    ///
    /// - Parameters:
    ///   - value: *Required.* The value to record.
    ///   - key: *Required.* The key used to address the value.
    func setValue<Value>(_ value: Value, forKey key: String)
    
    /// Removes the value from the store.
    ///
    /// - Parameter key: *Required.* The key used to address the value.
    func removeValue(forKey key: String)
    
}
