//
//  FeatureFlagValueTransformer.swift
//  YMFF
//
//  Created by Yakov Manshin on 2/5/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - Transformer

/// The object used to transform raw values into client-type values, and vice versa.
public struct FeatureFlagValueTransformer<RawValue, Value> {
    
    let valueFromRawValue: (RawValue) -> Value?
    let rawValueFromValue: (Value) -> RawValue
    
    /// Creates a new instance of transformer using the specified transformation closures.
    ///
    /// - Parameters:
    ///   - valueFromRawValue: *Required.* The closure which attempts to transform a raw value into a value.
    ///   - rawValueFromValue: *Required.* The closure which transforms a value into a raw value.
    public init(
        valueFromRawValue: @escaping (RawValue) -> Value?,
        rawValueFromValue: @escaping (Value) -> RawValue
    ) {
        self.valueFromRawValue = valueFromRawValue
        self.rawValueFromValue = rawValueFromValue
    }
    
}

// MARK: - Identity

extension FeatureFlagValueTransformer where RawValue == Value {
    
    /// The transformer which converts between values of the same type.
    static var identity: FeatureFlagValueTransformer {
        .init(valueFromRawValue: { $0 }, rawValueFromValue: { $0 })
    }
    
}
