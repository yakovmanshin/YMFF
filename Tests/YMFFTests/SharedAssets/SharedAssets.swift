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
        .init(stores: [
            .mutable(RuntimeOverridesStore()),
            .immutable(OpaqueStoreWithLimitedTypeSupport(store: remoteStore)),
            .immutable(FeatureFlagStore.transparent(localStore)),
        ])
    }
    
    static var configurationWithNoPersistentStores: FeatureFlagResolverConfiguration {
        .init(stores: [.mutable(RuntimeOverridesStore())])
    }
    
    static var configurationWithNoMutableStores: FeatureFlagResolverConfiguration {
        .init(stores: [
            .immutable(OpaqueStoreWithLimitedTypeSupport(store: remoteStore)),
            .immutable(FeatureFlagStore.transparent(localStore)),
        ])
    }
    
    static var configurationWithNoStores: FeatureFlagResolverConfiguration {
        .init(stores: [])
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
        case is Bool.Type,
             is Int.Type,
             is String.Type,
             is Optional<Bool>.Type,
             is Optional<Int>.Type,
             is Optional<String>.Type:
            return store[key] as? Value
        default:
            assertionFailure("The expected feature flag value type (\(expectedValueType)) is not supported")
            return nil
        }
    }
    
}
