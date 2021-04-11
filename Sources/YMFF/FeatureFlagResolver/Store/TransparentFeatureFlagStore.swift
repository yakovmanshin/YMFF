//
//  TransparentFeatureFlagStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

/// A simple dictionary used to store and retrieve feature flag values.
public typealias TransparentFeatureFlagStore = [String : Any]

extension TransparentFeatureFlagStore: FeatureFlagStoreProtocol {
    
    public func containsValue(forKey key: String) -> Bool {
        self[key] != nil
    }
    
    public func value<Value>(forKey key: String) -> Value? {
        self[key] as? Value
    }
    
}
