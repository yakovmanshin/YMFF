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
    var value_result: Result<Any, TestFeatureFlagStoreError>!
    
    var setValue_invocationCount = 0
    var setValue_keyValuePairs = [(String, Any)]()
    var setValue_result: Result<Void, TestFeatureFlagStoreError>!
    
    var removeValue_invocationCount = 0
    var removeValue_keys = [String]()
    var removeValue_result: Result<Void, TestFeatureFlagStoreError>!
    
    var saveChanges_invocationCount = 0
    var saveChanges_result: Result<Void, TestFeatureFlagStoreError>!
    
}

// MARK: - MutableFeatureFlagStore

extension MutableFeatureFlagStoreMock: MutableFeatureFlagStore {
    
    func containsValue(forKey key: String) async -> Bool {
        containsValue_invocationCount += 1
        containsValue_keys.append(key)
        return containsValue_returnValue
    }
    
    func value<Value>(forKey key: String) async throws -> Value {
        value_invocationCount += 1
        value_keys.append(key)
        switch value_result! {
        case .success(let anyValue):
            if let value = anyValue as? Value {
                return value
            } else {
                throw TestFeatureFlagStoreError.typeMismatch
            }
        case .failure(let error): throw error
        }
    }
    
    func setValue<Value>(_ value: Value, forKey key: String) async throws {
        setValue_invocationCount += 1
        setValue_keyValuePairs.append((key, value))
        if case .failure(let error) = setValue_result {
            throw error
        }
    }
    
    func removeValue(forKey key: String) async throws {
        removeValue_invocationCount += 1
        removeValue_keys.append(key)
        if case .failure(let error) = removeValue_result {
            throw error
        }
    }
    
    func saveChanges() async throws {
        saveChanges_invocationCount += 1
        if case .failure(let error) = saveChanges_result {
            throw error
        }
    }
    
}
