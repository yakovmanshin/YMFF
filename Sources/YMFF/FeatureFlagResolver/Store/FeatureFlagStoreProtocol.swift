//
//  FeatureFlagStoreProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that stores feature flag values.
public protocol FeatureFlagStoreProtocol {
    
    /// Retrieves feature flag value by its key.
    ///
    /// - Parameter key: *Required.* The key that points to a feature flag value in the store.
    func value(forKey key: String) -> Any?
    
}
