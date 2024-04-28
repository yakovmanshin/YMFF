//
//  SynchronousFeatureFlagResolverProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 4/28/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousFeatureFlagResolverProtocol: FeatureFlagResolverProtocol {
    
    func valueSync<Value>(for key: FeatureFlagKey) throws -> Value
    
    func setValueSync<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) throws
    
    func removeValueFromMutableStoreSync(using key: FeatureFlagKey) throws
    
}

extension SynchronousFeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) async throws -> Value {
        try valueSync(for: key)
    }
    
    public func setValue<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) async throws {
        try setValueSync(newValue, toMutableStoreUsing: key)
    }
    
    public func removeValueFromMutableStore(using key: FeatureFlagKey) async throws {
        try removeValueFromMutableStoreSync(using: key)
    }
    
}
