//
//  FeatureFlag.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

@propertyWrapper
public struct FeatureFlag<Value> {
    
    // MARK: Properties
    
    private let key: FeatureFlagKey
    private let defaultValue: Value
    private let resolver: FeatureFlagResolverProtocol
    
    // MARK: Initializers
    
    public init(
        _ keyString: String,
        default defaultValue: Value,
        resolver: FeatureFlagResolverProtocol
    ) {
        self.key = FeatureFlagKey(keyString)
        self.defaultValue = defaultValue
        self.resolver = resolver
    }
    
    // MARK: Wrapped Value
    
    public var wrappedValue: Value {
        get {
            resolver.value(for: key) ?? defaultValue
        } set {
            try? resolver.overrideInRuntime(key, with: newValue)
        }
    }
    
}
