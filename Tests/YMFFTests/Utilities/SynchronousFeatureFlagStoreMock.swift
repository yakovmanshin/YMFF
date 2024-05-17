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
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [String]()
    var valueSync_result: Result<Any, FeatureFlagStoreError>!
    
}

// MARK: - SynchronousFeatureFlagStore

extension SynchronousFeatureFlagStoreMock: SynchronousFeatureFlagStore {
    
    func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError> {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        return switch valueSync_result! {
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
