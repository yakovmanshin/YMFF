//
//  UserDefaultsStore.swift
//  YMFF
//
//  Created by Yakov Manshin on 3/25/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if canImport(Foundation)

import Foundation
#if !COCOAPODS
import YMFFProtocols
#endif

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

// MARK: - SynchronousMutableFeatureFlagStore

extension UserDefaultsStore: SynchronousMutableFeatureFlagStore {
    
    public func containsValueSync(forKey key: String) -> Bool {
        userDefaults.object(forKey: key) != nil
    }
    
    public func valueSync<Value>(forKey key: String) throws -> Value {
        guard let anyValue = userDefaults.object(forKey: key) else {
            throw CommonFeatureFlagStoreError.valueNotFound(key: key)
        }
        guard let value = anyValue as? Value else { throw CommonFeatureFlagStoreError.typeMismatch }
        return value
    }
    
    public func setValueSync<Value>(_ value: Value, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func removeValueSync(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    public func saveChangesSync() {
        userDefaults.synchronize()
    }
    
}

#endif
