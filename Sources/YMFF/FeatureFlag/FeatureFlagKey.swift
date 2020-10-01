//
//  FeatureFlagKey.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// A structure that contains information about the keys used to retrieve feature flag values from the corresponding stores.
public struct FeatureFlagKey {
    
    let localKey: String
    let remoteKey: String
    
    private init(local localKey: String, remote remoteKey: String) {
        self.localKey = localKey
        self.remoteKey = remoteKey
    }
    
    /// Initializes a `FeatureFlagKey` instance with the same key used for local and remote stores.
    ///
    /// - Parameter key: *Required.* The key to use for value retrieval.
    public init(_ key: String) {
        self.init(local: key, remote: key)
    }
    
}
