//
//  FeatureFlagStoreMock.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 4/29/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

// MARK: - Mock

final class SynchronousMutableFeatureFlagStoreMock {
    
    var containsValueSync_invocationCount = 0
    var containsValueSync_keys = [String]()
    var containsValueSync_returnValue: Bool!
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [String]()
    var valueSync_returnValue: Any?
    
    var setValueSync_invocationCount = 0
    var setValueSync_keyValuePairs = [(String, Any)]()
    
    var removeValueSync_invocationCount = 0
    var removeValueSync_keys = [String]()
    
    var saveChangesSync_invocationCount = 0
    
}

// MARK: - SynchronousMutableFeatureFlagStoreProtocol

extension SynchronousMutableFeatureFlagStoreMock: SynchronousMutableFeatureFlagStoreProtocol {
    
    func containsValueSync(forKey key: String) -> Bool {
        containsValueSync_invocationCount += 1
        containsValueSync_keys.append(key)
        return containsValueSync_returnValue
    }
    
    func valueSync<Value>(forKey key: String) -> Value? {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        if let valueSync_returnValue {
            return valueSync_returnValue as? Value? ?? nil
        } else {
            return nil
        }
    }
    
    func setValueSync<Value>(_ value: Value, forKey key: String) {
        setValueSync_invocationCount += 1
        setValueSync_keyValuePairs.append((key, value))
    }
    
    func removeValueSync(forKey key: String) {
        removeValueSync_invocationCount += 1
        removeValueSync_keys.append(key)
    }
    
    func saveChangesSync() {
        saveChangesSync_invocationCount += 1
    }
    
}
