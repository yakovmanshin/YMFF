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
    var valueSync_returnValue: Any?
    
}

// MARK: - SynchronousFeatureFlagStoreProtocol

extension SynchronousFeatureFlagStoreMock: SynchronousFeatureFlagStoreProtocol {
    
    func containsValueSync(forKey key: String) -> Bool {
        containsValueSync_invocationCount += 1
        containsValueSync_keys.append(key)
        return containsValueSync_returnValue
    }
    
    func valueSync<Value>(forKey key: String) -> Value? {
        valueSync_invocationCount += 1
        valueSync_keys.append(key)
        if let valueSync_returnValue {
            return valueSync_returnValue as? Value? ?? nil
        } else {
            return nil
        }
    }
    
}
