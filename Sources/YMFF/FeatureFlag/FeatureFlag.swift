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

/// The object which provides easy access to feature-flag values.
@propertyWrapper
final public class FeatureFlag<RawValue, Value> {
    
    // MARK: Properties
    
    /// The key used to retrieve feature-flag values.
    public let key: FeatureFlagKey
    
    private let transformer: FeatureFlagValueTransformer<RawValue, Value>
    
    /// The fallback value returned when the actual one cannot be retrieved.
    public let defaultValue: Value
    
    private let resolver: any SynchronousFeatureFlagResolverProtocol
    
    // MARK: Initializers
    
    /// Creates a new `FeatureFlag`.
    /// 
    /// - Parameters:
    ///   - key: *Required.* The key used to address feature-flag values in stores.
    ///   - transformer: *Required.* The object that transforms raw values into client-type values, and vice versa.
    ///   - defaultValue: *Required.* The value returned in case no feature-flag store is able provide a value.
    ///   - resolver: *Required.* The resolver object used to retrieve values from stores.
    public init(
        _ key: FeatureFlagKey,
        transformer: FeatureFlagValueTransformer<RawValue, Value>,
        default defaultValue: Value,
        resolver: any SynchronousFeatureFlagResolverProtocol
    ) {
        self.key = key
        self.transformer = transformer
        self.defaultValue = defaultValue
        self.resolver = resolver
    }
    
    /// Creates a new `FeatureFlag` whose value and raw value are of the same type.
    ///
    /// - Parameters:
    ///   - key: *Required.* The key used to address feature-flag values in stores.
    ///   - defaultValue: *Required.* The value returned in case no feature-flag store is able provide a value.
    ///   - resolver: *Required.* The resolver object used to retrieve values from stores.
    public convenience init(
        _ key: FeatureFlagKey,
        default defaultValue: Value,
        resolver: any SynchronousFeatureFlagResolverProtocol
    ) where RawValue == Value {
        self.init(key, transformer: .identity, default: defaultValue, resolver: resolver)
    }
    
    // MARK: Wrapped Value
    
    /// The resolved value of the feature flag.
    public var wrappedValue: Value {
        get {
            guard
                let rawValue = try? (resolver.valueSync(for: key) as RawValue),
                let value = transformer.valueFromRawValue(rawValue)
            else { return defaultValue }
            
            return value
        } set {
            try? resolver.setValueSync(transformer.rawValueFromValue(newValue), for: key)
        }
    }
    
    // MARK: Projected Value
    
    /// The feature-flag object itself, returned when the feature flag is referenced with a dollar sign (`$`).
    public var projectedValue: FeatureFlag<RawValue, Value> { self }
    
    // MARK: Mutable Value Removal
    
    /// Removes the value from all *synchronous* mutable feature-flag stores.
    ///
    /// + Errors thrown by `resolver` are ignored.
    public func removeValueFromMutableStores() {
        try? resolver.removeValueSync(for: key)
    }
    
}
