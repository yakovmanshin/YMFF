//
//  FeatureFlag.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

/// An object that facilitates access to feature flag values.
@propertyWrapper
final public class FeatureFlag<Value> {
    
    // MARK: Properties
    
    /// The key used to retrieve feature flag values.
    public let key: FeatureFlagKey
    
    /// The fallback value returned when no store is able to provide the real one.
    public let defaultValue: Value
    
    private let resolver: FeatureFlagResolverProtocol
    
    // MARK: Initializers
    
    /// Creates a new `FeatureFlag`.
    ///
    /// - Parameters:
    ///   - key: *Required.* The key used to address feature flag values in stores.
    ///   - defaultValue: *Required.* The value returned in case all stores fail to provide a value.
    ///   - resolver: *Required.* The resolver object used to retrieve values from stores.
    public init(
        _ key: FeatureFlagKey,
        default defaultValue: Value,
        resolver: FeatureFlagResolverProtocol
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.resolver = resolver
    }
    
    // MARK: Wrapped Value
    
    /// The resolved value of the feature flag.
    public var wrappedValue: Value {
        get {
            (try? (resolver.value(for: key) as Value)) ?? defaultValue
        } set {
            try? resolver.overrideInRuntime(key, with: newValue)
        }
    }
    
    // MARK: Projected Value
    
    /// The object returned when referencing the feature flag with a dollar sign (`$`).
    public var projectedValue: FeatureFlag<Value> { self }
    
    // MARK: Runtime Overrides
    
    /// Removes the feature flag value that overrides persistent values in runtime.
    public func removeRuntimeOverride() {
        try? resolver.removeValueFromMutableStore(using: key)
    }
    
}
