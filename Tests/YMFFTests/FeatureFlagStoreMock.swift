//
//  FeatureFlagStoreMock.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 4/29/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

// MARK: - Mock

final class FeatureFlagStoreMock {
    
    var containsValue_invocationCount = 0
    var containsValue_keys = [String]()
    var containsValue_returnValue: Bool!
    
    var value_invocationCount = 0
    var value_keys = [String]()
    var value_returnValue: Any?
    
}

// MARK: - FeatureFlagStoreProtocol

extension FeatureFlagStoreMock: FeatureFlagStoreProtocol {
    
    func containsValue(forKey key: String) async -> Bool {
        containsValue_invocationCount += 1
        containsValue_keys.append(key)
        return containsValue_returnValue
    }
    
    func value<Value>(forKey key: String) async -> Value? {
        value_invocationCount += 1
        value_keys.append(key)
        if let value_returnValue {
            return value_returnValue as! Value?
        } else {
            return nil
        }
    }
    
}
