//
//  SynchronousFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousFeatureFlagStoreProtocol: FeatureFlagStoreProtocol {
    
    func containsValueSync(forKey key: String) -> Bool
    
    func valueSync<Value>(forKey key: String) -> Value?
    
}

extension SynchronousFeatureFlagStoreProtocol {
    
    public func containsValue(forKey key: String) async -> Bool {
        containsValueSync(forKey: key)
    }
    
    public func value<Value>(forKey key: String) async -> Value? {
        valueSync(forKey: key)
    }
    
}
