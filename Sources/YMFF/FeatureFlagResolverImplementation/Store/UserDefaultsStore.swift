//
//  UserDefaultsStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 3/25/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)

import Foundation

// MARK: - UserDefaultsStore

final public class UserDefaultsStore {
    
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
}

// MARK: - MutableFeatureFlagStoreProtocol

extension UserDefaultsStore: MutableFeatureFlagStoreProtocol {
    
    public func value<Value>(forKey key: String) -> Value? {
        userDefaults.value(forKey: key) as? Value
    }
    
    public func setValue<Value>(_ value: Value, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
}

#endif
