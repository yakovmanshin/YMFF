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
    
    var value_invocationCount = 0
    var value_keys = [String]()
    var value_result: Result<Any, FeatureFlagStoreError>!
    
    var setValue_invocationCount = 0
    var setValue_keyValuePairs = [(String, Any)]()
    var setValue_result: Result<Void, TestFeatureFlagStoreError>!
    
    var removeValue_invocationCount = 0
    var removeValue_keys = [String]()
    var removeValue_result: Result<Void, TestFeatureFlagStoreError>!
    
}

// MARK: - MutableFeatureFlagStore

extension MutableFeatureFlagStoreMock: MutableFeatureFlagStore {
    
    func value<Value>(for key: FeatureFlagKey) async -> Result<Value, FeatureFlagStoreError> {
        value_invocationCount += 1
        value_keys.append(key)
        switch value_result! {
        case .success(let anyValue):
            if let value = anyValue as? Value {
                return .success(value)
            } else {
                return .failure(.typeMismatch)
            }
        case .failure(let error): return .failure(error)
        }
    }
    
    func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws {
        setValue_invocationCount += 1
        setValue_keyValuePairs.append((key, value))
        if case .failure(let error) = setValue_result {
            throw error
        }
    }
    
    func removeValue(for key: FeatureFlagKey) async throws {
        removeValue_invocationCount += 1
        removeValue_keys.append(key)
        if case .failure(let error) = removeValue_result {
            throw error
        }
    }
    
}
