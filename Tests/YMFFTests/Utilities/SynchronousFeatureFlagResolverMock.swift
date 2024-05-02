//
//  SynchronousFeatureFlagResolverMock.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 4/28/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

#if COCOAPODS
import YMFF
#else
import YMFFProtocols
#endif

// MARK: - Mock

final class SynchronousFeatureFlagResolverMock {
    
    var configuration_invocationCount = 0
    var configuration_returnValue: (any FeatureFlagResolverConfiguration)!
    
    var valueSync_invocationCount = 0
    var valueSync_keys = [FeatureFlagKey]()
    var valueSync_result: Result<Any, any Error>!
    
    var setValueSync_invocationCount = 0
    var setValueSync_keyValuePairs = [(FeatureFlagKey, Any)]()
    var setValueSync_result: Result<Void, any Error>!
    
    var removeValueFromMutableStoreSync_invocationCount = 0
    var removeValueFromMutableStoreSync_keys = [FeatureFlagKey]()
    var removeValueFromMutableStoreSync_result: Result<Void, any Error>!
    
}

// MARK: - SynchronousFeatureFlagResolverProtocol

extension SynchronousFeatureFlagResolverMock: SynchronousFeatureFlagResolverProtocol {
    
    var configuration: any FeatureFlagResolverConfiguration {
        configuration_invocationCount += 1
        return configuration_returnValue
    }
    
    func valueSync<Value>(for key: FeatureFlagKey) throws -> Value {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        switch valueSync_result! {
        case .success(let value):
            return value as! Value
        case .failure(let error):
            throw error
        }
    }
    
    func setValueSync<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) throws {
        setValueSync_invocationCount += 1
        setValueSync_keyValuePairs.append((key, newValue))
        if case .failure(let error) = setValueSync_result {
            throw error
        }
    }
    
    func removeValueFromMutableStoreSync(using key: FeatureFlagKey) throws {
        removeValueFromMutableStoreSync_invocationCount += 1
        removeValueFromMutableStoreSync_keys.append(key)
        if case .failure(let error) = removeValueFromMutableStoreSync_result {
            throw error
        }
    }
    
}
