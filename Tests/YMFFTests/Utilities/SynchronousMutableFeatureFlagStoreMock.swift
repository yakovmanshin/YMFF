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
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [String]()
    var valueSync_result: Result<Any, FeatureFlagStoreError>!
    
    var setValueSync_invocationCount = 0
    var setValueSync_keyValuePairs = [(String, Any)]()
    var setValueSync_result: Result<Void, TestFeatureFlagStoreError>!
    
    var removeValueSync_invocationCount = 0
    var removeValueSync_keys = [String]()
    var removeValueSync_result: Result<Void, TestFeatureFlagStoreError>!
    
}

// MARK: - SynchronousMutableFeatureFlagStore

extension SynchronousMutableFeatureFlagStoreMock: SynchronousMutableFeatureFlagStore {
    
    func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError> {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        switch valueSync_result! {
        case .success(let anyValue):
            if let value = anyValue as? Value {
                return .success(value)
            } else {
                return .failure(.typeMismatch)
            }
        case .failure(let error): return .failure(error)
        }
    }
    
    func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) throws {
        setValueSync_invocationCount += 1
        setValueSync_keyValuePairs.append((key, value))
        if case .failure(let error) = setValueSync_result {
            throw error
        }
    }
    
    func removeValueSync(for key: FeatureFlagKey) throws {
        removeValueSync_invocationCount += 1
        removeValueSync_keys.append(key)
        if case .failure(let error) = removeValueSync_result {
            throw error
        }
    }
    
}
