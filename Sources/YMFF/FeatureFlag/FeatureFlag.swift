//
//  FeatureFlag.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that facilitates access to feature flag values.
@propertyWrapper
public struct FeatureFlag<Value> {
    
    // MARK: Properties
    
    private let key: FeatureFlagKey
    private let defaultValue: Value
    private let resolver: FeatureFlagResolverProtocol
    
    // MARK: Initializers
    
    /// Creates a new `FeatureFlag`.
    ///
    /// - Parameters:
    ///   - keyString: *Required.* The string used to address feature flag values in both the local and remote stores.
    ///   - defaultValue: *Required.* The value returned in case both the local and remote stores failed to provide values by the key.
    ///   - resolver: *Required.* The resolver object used to retrieve values from the stores.
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
    
    /// The resolved value of the feature flag.
    public var wrappedValue: Value {
        get {
            resolver.value(for: key) ?? defaultValue
        } set {
            try? resolver.overrideInRuntime(key, with: newValue)
        }
    }
    
}
