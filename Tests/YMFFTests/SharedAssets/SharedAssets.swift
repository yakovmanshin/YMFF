//
//  SharedAssets.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFF

// MARK: - Shared

enum SharedAssets {
    
    static var configuration: FeatureFlagResolverConfiguration {
        .init(persistentStores: [.opaque(OpaqueStoreStab(store: remoteStore)), .transparent(localStore)])
    }
    
    private static var localStore: [String : Any] { [
        "bool": false,
        "int": 123,
        "string": "STRING_VALUE_LOCAL",
        "optionalIntNonNil": Optional<Int>.some(123) as Any,
        "intToOverride": 123,
    ] }
    
    private static var remoteStore: [String : Any] { [
        "bool": true,
        "string": "STRING_VALUE_REMOTE",
        "optionalIntNil": Optional<Int>.none as Any,
        "optionalIntNonNil": Optional<Int>.some(456) as Any,
        "intToOverride": 456,
    ] }
    
    static var boolKey: FeatureFlagKey { .init("bool") }
    static var intKey: FeatureFlagKey { .init("int") }
    static var stringKey: FeatureFlagKey { .init("string") }
    static var optionalIntNilKey: FeatureFlagKey { .init("optionalIntNil") }
    static var optionalIntNonNilKey: FeatureFlagKey { .init("optionalIntNonNil") }
    static var nonexistentKey: FeatureFlagKey { .init("nonexistent") }
    static var intToOverrideKey: FeatureFlagKey { .init("intToOverride") }
    
}

// MARK: - Supplementary Types

fileprivate struct OpaqueStoreStab: FeatureFlagStoreProtocol {
    
    let store: TransparentFeatureFlagStore
    
    func value(forKey key: String) -> Any? {
        store[key]
    }
    
}
