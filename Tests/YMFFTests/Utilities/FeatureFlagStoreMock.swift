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

final class FeatureFlagStoreMock {
    
    var containsValue_invocationCount = 0
    var containsValue_keys = [String]()
    var containsValue_returnValue: Bool!
    
    var value_invocationCount = 0
    var value_keys = [String]()
    var value_result: Result<Any, TestFeatureFlagStoreError>!
    
}

// MARK: - FeatureFlagStore

extension FeatureFlagStoreMock: FeatureFlagStore {
    
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
    
}
