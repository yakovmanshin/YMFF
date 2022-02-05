//
//  FeatureFlagValueTransformer.swift
//  YMFF
//
//  Created by Yakov Manshin on 2/5/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - Transformer

public struct FeatureFlagValueTransformer<RawValue, Value> {
    
    let valueFromRawValue: (RawValue) -> Value
    let rawValueFromValue: (Value) -> RawValue
    
    public init(
        valueFromRawValue: @escaping (RawValue) -> Value,
        rawValueFromValue: @escaping (Value) -> RawValue
    ) {
        self.valueFromRawValue = valueFromRawValue
        self.rawValueFromValue = rawValueFromValue
    }
    
}

// MARK: - Identity

extension FeatureFlagValueTransformer where RawValue == Value {
    
    static var identity: FeatureFlagValueTransformer {
        .init(valueFromRawValue: { $0 }, rawValueFromValue: { $0 })
    }
    
}
