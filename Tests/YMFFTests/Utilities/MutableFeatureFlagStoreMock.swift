//
//  FeatureFlagStoreMock.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 4/29/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

#if COCOAPODS
import YMFF
#else
import YMFFProtocols
#endif

// MARK: - Mock

final class MutableFeatureFlagStoreMock {
    
    var containsValue_invocationCount = 0
    var containsValue_keys = [String]()
    var containsValue_returnValue: Bool!
    
    var value_invocationCount = 0
    var value_keys = [String]()
    var value_returnValue: Any?
    
    var setValue_invocationCount = 0
    var setValue_keyValuePairs = [(String, Any)]()
    
    var removeValue_invocationCount = 0
    var removeValue_keys = [String]()
    
    var saveChanges_invocationCount = 0
    
}

// MARK: - MutableFeatureFlagStore

extension MutableFeatureFlagStoreMock: MutableFeatureFlagStore {
    
    func containsValue(forKey key: String) async -> Bool {
        containsValue_invocationCount += 1
        containsValue_keys.append(key)
        return containsValue_returnValue
    }
    
    func value<Value>(forKey key: String) async -> Value? {
        value_invocationCount += 1
        value_keys.append(key)
        if let value_returnValue {
            return value_returnValue as? Value? ?? nil
        } else {
            return nil
        }
    }
    
    func setValue<Value>(_ value: Value, forKey key: String) async {
        setValue_invocationCount += 1
        setValue_keyValuePairs.append((key, value))
    }
    
    func removeValue(forKey key: String) async {
        removeValue_invocationCount += 1
        removeValue_keys.append(key)
    }
    
    func saveChanges() async {
        saveChanges_invocationCount += 1
    }
    
}
