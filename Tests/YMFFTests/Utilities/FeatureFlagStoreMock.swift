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
    
    var value_invocationCount = 0
    var value_keys = [String]()
    var value_result: Result<Any, FeatureFlagStoreError>!
    
}

// MARK: - FeatureFlagStore

extension FeatureFlagStoreMock: FeatureFlagStore {
    
    func value<Value>(forKey key: String) async -> Result<Value, FeatureFlagStoreError> {
        value_invocationCount += 1
        value_keys.append(key)
        return switch value_result! {
        case .success(let anyValue):
            if let value = anyValue as? Value {
                .success(value)
            } else {
                .failure(.typeMismatch)
            }
        case .failure(let error): .failure(error)
        }
    }
    
}
