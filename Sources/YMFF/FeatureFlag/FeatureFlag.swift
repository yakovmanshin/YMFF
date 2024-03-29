//
//  FeatureFlag.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

/// An object that facilitates access to feature flag values.
@propertyWrapper
final public class FeatureFlag<RawValue, Value> {
    
    // MARK: Properties
    
    /// The key used to retrieve feature flag values.
    public let key: FeatureFlagKey
    
    private let transformer: FeatureFlagValueTransformer<RawValue, Value>
    
    /// The fallback value returned when no store is able to provide the real one.
    public let defaultValue: Value
    
    private let resolver: FeatureFlagResolverProtocol
    
    // MARK: Initializers
    
    /// Creates a new `FeatureFlag`.
    ///
    /// - Parameters:
    ///   - key: *Required.* The key used to address feature flag values in stores.
    ///   - transformer: *Required.* The object that transforms raw values into values, and vice versa.
    ///   - defaultValue: *Required.* The value returned in case all stores fail to provide a value.
    ///   - resolver: *Required.* The resolver object used to retrieve values from stores.
    public init(
        _ key: FeatureFlagKey,
        transformer: FeatureFlagValueTransformer<RawValue, Value>,
        default defaultValue: Value,
        resolver: FeatureFlagResolverProtocol
    ) {
        self.key = key
        self.transformer = transformer
        self.defaultValue = defaultValue
        self.resolver = resolver
    }
    
    /// Creates a new `FeatureFlag` with value and raw value of the same type.
    ///
    /// - Parameters:
    ///   - key: *Required.* The key used to address feature flag values in stores.
    ///   - defaultValue: *Required.* The value returned in case all stores fail to provide a value.
    ///   - resolver: *Required.* The resolver object used to retrieve values from stores.
    public convenience init(
        _ key: FeatureFlagKey,
        default defaultValue: Value,
        resolver: FeatureFlagResolverProtocol
    ) where RawValue == Value {
        self.init(key, transformer: .identity, default: defaultValue, resolver: resolver)
    }
    
    // MARK: Wrapped Value
    
    /// The resolved value of the feature flag.
    public var wrappedValue: Value {
        get {
            guard
                let rawValue = try? (resolver.value(for: key) as RawValue),
                let value = transformer.valueFromRawValue(rawValue)
            else { return defaultValue }
            
            return value
        } set {
            try? resolver.setValue(transformer.rawValueFromValue(newValue), toMutableStoreUsing: key)
        }
    }
    
    // MARK: Projected Value
    
    /// The object returned when referencing the feature flag with a dollar sign (`$`).
    public var projectedValue: FeatureFlag<RawValue, Value> { self }
    
    // MARK: Mutable Value Removal
    
    /// Removes the value from the first mutable feature flag store which contains one for `key`.
    ///
    /// + Errors thrown by `resolver` are ignored.
    public func removeValueFromMutableStore() {
        try? resolver.removeValueFromMutableStore(using: key)
    }
    
}
