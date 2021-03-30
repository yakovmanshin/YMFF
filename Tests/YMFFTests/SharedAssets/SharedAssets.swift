//
//  SharedAssets.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFF
import YMFFProtocols

// MARK: - Shared

enum SharedAssets {
    
    static var configuration: FeatureFlagResolverConfiguration {
        .init(persistentStores: [
            .opaque(OpaqueStoreWithLimitedTypeSupport(store: remoteStore)),
            .transparent(localStore)
        ])
    }
    
    static var configurationWithNoPersistentStores: FeatureFlagResolverConfiguration {
        .init(persistentStores: [])
    }
    
    private static var localStore: [String : Any] { [
        "bool": false,
        "int": 123,
        "string": "STRING_VALUE_LOCAL",
        "optionalInt": Optional<Int>.some(123) as Any,
        "intToOverride": 123,
    ] }
    
    private static var remoteStore: [String : Any] { [
        "bool": true,
        "string": "STRING_VALUE_REMOTE",
        "optionalInt": Optional<Int>.none as Any,
        "intToOverride": 456,
    ] }
    
    static var boolKey: FeatureFlagKey { "bool" }
    static var intKey: FeatureFlagKey { "int" }
    static var stringKey: FeatureFlagKey { "string" }
    static var optionalIntKey: FeatureFlagKey { "optionalInt" }
    static var nonexistentKey: FeatureFlagKey { "nonexistent" }
    static var intToOverrideKey: FeatureFlagKey { "intToOverride" }
    
}

// MARK: - Supplementary Types

private struct OpaqueStoreWithLimitedTypeSupport: FeatureFlagStoreProtocol {
    
    private let store: TransparentFeatureFlagStore
    
    init(store: TransparentFeatureFlagStore) {
        self.store = store
    }
    
    func containsValue(forKey key: String) -> Bool {
        store[key] != nil
    }
    
    func value<Value>(forKey key: String) -> Value? {
        let expectedValueType = Value.self
        
        switch expectedValueType {
        case is Bool.Type:
            return store[key] as? Value
        case is Int.Type:
            return store[key] as? Value
        case is String.Type:
            return store[key] as? Value
        default:
            assertionFailure("The expected feature flag value type (\(expectedValueType)) is not supported")
            return nil
        }
    }
    
}
