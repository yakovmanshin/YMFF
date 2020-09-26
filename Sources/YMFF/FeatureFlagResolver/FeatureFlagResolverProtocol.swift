//
//  FeatureFlagResolverProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

public protocol FeatureFlagResolverProtocol {
    
    var configuration: FeatureFlagResolverConfigurationProtocol { get }
    
    func value<Value>(for key: FeatureFlagKey) -> Value?
    
    func overrideInRuntime<Value>(_ key: FeatureFlagKey, with newValue: Value) throws
    
    func removeRuntimeOverride(for key: FeatureFlagKey)
    
}
