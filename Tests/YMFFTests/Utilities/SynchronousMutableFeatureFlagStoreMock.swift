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

final class SynchronousMutableFeatureFlagStoreMock {
    
    var containsValueSync_invocationCount = 0
    var containsValueSync_keys = [String]()
    var containsValueSync_returnValue: Bool!
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [String]()
    var valueSync_result: Result<Any, TestFeatureFlagStoreError>!
    
    var setValueSync_invocationCount = 0
    var setValueSync_keyValuePairs = [(String, Any)]()
    var setValueSync_result: Result<Void, TestFeatureFlagStoreError>!
    
    var removeValueSync_invocationCount = 0
    var removeValueSync_keys = [String]()
    var removeValueSync_result: Result<Void, TestFeatureFlagStoreError>!
    
    var saveChangesSync_invocationCount = 0
    var saveChangesSync_result: Result<Void, TestFeatureFlagStoreError>!
    
}

// MARK: - SynchronousMutableFeatureFlagStore

extension SynchronousMutableFeatureFlagStoreMock: SynchronousMutableFeatureFlagStore {
    
    func containsValueSync(forKey key: String) -> Bool {
        containsValueSync_invocationCount += 1
        containsValueSync_keys.append(key)
        return containsValueSync_returnValue
    }
    
    func valueSync<Value>(forKey key: String) throws -> Value {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        switch valueSync_result! {
        case .success(let anyValue):
            if let value = anyValue as? Value {
                return value
            } else {
                throw TestFeatureFlagStoreError.typeMismatch
            }
        case .failure(let error): throw error
        }
    }
    
    func setValueSync<Value>(_ value: Value, forKey key: String) throws {
        setValueSync_invocationCount += 1
        setValueSync_keyValuePairs.append((key, value))
        if case .failure(let error) = setValueSync_result {
            throw error
        }
    }
    
    func removeValueSync(forKey key: String) throws {
        removeValueSync_invocationCount += 1
        removeValueSync_keys.append(key)
        if case .failure(let error) = removeValueSync_result {
            throw error
        }
    }
    
    func saveChangesSync() throws {
        saveChangesSync_invocationCount += 1
        if case .failure(let error) = saveChangesSync_result {
            throw error
        }
    }
    
}
