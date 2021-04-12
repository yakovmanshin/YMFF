//
//  UserDefaultsStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 3/25/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)

import Foundation
import YMFFProtocols

// MARK: - UserDefaultsStore

/// An object that provides read and write access to feature flag values store in `UserDefaults`.
final public class UserDefaultsStore {
    
    private let userDefaults: UserDefaults
    
    /// Initializes a new `UserDefaultsStore`.
    ///
    /// - Parameter userDefaults: *Optional.* The `UserDefaults` object used to read and write values.
    /// `UserDefaults.standard` is used by default.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
}

// MARK: - MutableFeatureFlagStoreProtocol

extension UserDefaultsStore: MutableFeatureFlagStoreProtocol {
    
    public func containsValue(forKey key: String) -> Bool {
        userDefaults.object(forKey: key) != nil
    }
    
    public func value<Value>(forKey key: String) -> Value? {
        userDefaults.object(forKey: key) as? Value
    }
    
    public func setValue<Value>(_ value: Value, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
}

#endif
