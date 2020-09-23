//
//  FeatureFlagKey.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

public struct FeatureFlagKey {
    
    let localKey: String
    let remoteKey: String
    
    private init(local localKey: String, remote remoteKey: String) {
        self.localKey = localKey
        self.remoteKey = remoteKey
    }
    
    public init(_ key: String) {
        self.init(local: key, remote: key)
    }
    
}
