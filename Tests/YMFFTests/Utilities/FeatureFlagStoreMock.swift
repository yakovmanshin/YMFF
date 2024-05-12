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
    
}
