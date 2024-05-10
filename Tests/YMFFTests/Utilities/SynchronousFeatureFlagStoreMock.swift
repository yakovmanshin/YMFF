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

final class SynchronousFeatureFlagStoreMock {
    
    var containsValueSync_invocationCount = 0
    var containsValueSync_keys = [String]()
    var containsValueSync_returnValue: Bool!
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [String]()
    var valueSync_result: Result<Any, TestFeatureFlagStoreError>!
    
}

// MARK: - SynchronousFeatureFlagStore

extension SynchronousFeatureFlagStoreMock: SynchronousFeatureFlagStore {
    
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
    
}
