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

/// The object which provides read and write access to feature-flag values stored in `UserDefaults`.
final public class UserDefaultsStore {
    
    private let userDefaults: UserDefaults
    
    /// Initializes a new `UserDefaultsStore`.
    ///
    /// - Parameter userDefaults: *Optional.* The `UserDefaults` object used to read and write values.
    /// `UserDefaults.standard` is used by default.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    deinit {
        userDefaults.synchronize()
    }
    
}

// MARK: - SynchronousMutableFeatureFlagStore

extension UserDefaultsStore: SynchronousMutableFeatureFlagStore {
    
    public func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError> {
        guard !(Value.self is ExpressibleByNilLiteral.Type) else {
            return .failure(.otherError(Error.optionalValuesAreNotSupported))
        }
        
        guard let anyValue = userDefaults.object(forKey: key) else { return .failure(.valueNotFound) }
        guard let value = anyValue as? Value else { return .failure(.typeMismatch) }
        return .success(value)
    }
    
    public func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) throws {
        guard !(value is ExpressibleByNilLiteral) else {
            throw FeatureFlagStoreError.otherError(Error.optionalValuesAreNotSupported)
        }
        
        userDefaults.set(value, forKey: key)
    }
    
    public func removeValueSync(for key: FeatureFlagKey) {
        userDefaults.removeObject(forKey: key)
    }
    
}

// MARK: - Error

extension UserDefaultsStore {
    
    enum Error: Swift.Error {
        case optionalValuesAreNotSupported
    }
    
}

#endif
