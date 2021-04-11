//
//  FeatureFlagResolver.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

// MARK: - FeatureFlagResolver

/// A concrete, YMFF-supplied implementation of the feature flag resolver.
final public class FeatureFlagResolver {
    
    // MARK: Properties
    
    public let configuration: FeatureFlagResolverConfigurationProtocol
    
    // MARK: Initializers
    
    public init(configuration: FeatureFlagResolverConfiguration) {
        self.configuration = configuration
    }
    
}

// MARK: - FeatureFlagResolverProtocol

extension FeatureFlagResolver: FeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) throws -> Value {
        let retrievedValue: Value = try retrieveFirstValueFoundInStores(byKey: key)
        try validateValue(retrievedValue)
        
        return retrievedValue
    }
    
    public func overrideInRuntime<Value>(_ key: FeatureFlagKey, with newValue: Value) throws {
        try validateOverrideValue(newValue, forKey: key)
        configuration.runtimeStore.setValue(newValue, forKey: key)
    }
    
    public func removeRuntimeOverride(for key: FeatureFlagKey) {
        configuration.runtimeStore.removeValue(forKey: key)
    }
    
}

// MARK: Value Resolution

extension FeatureFlagResolver {
    
    func retrieveFirstValueFoundInStores<Value>(byKey key: String) throws -> Value {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        for store in configuration.stores {
            if store.asImmutable.containsValue(forKey: key) {
                guard let value: Value = store.asImmutable.value(forKey: key)
                else { throw FeatureFlagResolverError.typeMismatch }
                
                return value
            }
        }
        
        throw FeatureFlagResolverError.valueNotFoundInPersistentStores(key: key)
    }
    
    func validateValue<Value>(_ value: Value) throws {
        if valueIsOptional(value) {
            throw FeatureFlagResolverError.optionalValuesNotAllowed
        }
    }
    
    func valueIsOptional<Value>(_ value: Value) -> Bool {
        value is ExpressibleByNilLiteral
    }
    
}

// MARK: - Overriding

extension FeatureFlagResolver {
    
    func validateOverrideValue<Value>(_ value: Value, forKey key: FeatureFlagKey) throws {
        try validateValue(value)
        
        do {
            let _: Value = try retrieveFirstValueFoundInStores(byKey: key)
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores {
            // If none of the persistent stores contains a value for the key, then the client is attempting
            // to set a new value (instead of overriding an existing one). That’s an acceptable use case.
        } catch {
            throw error
        }
    }
    
    private func findFirstMutableStore() throws -> MutableFeatureFlagStoreProtocol {
        let mutableStores = try findMutableStores()
        return mutableStores[0]
    }
    
    private func findMutableStores() throws -> [MutableFeatureFlagStoreProtocol] {
        var stores = [MutableFeatureFlagStoreProtocol]()
        
        for store in configuration.stores {
            if case .mutable(let mutableStore) = store {
                stores.append(mutableStore)
            }
        }
        
        if stores.isEmpty {
            throw FeatureFlagResolverError.noMutableStoreAvailable
        }
        
        return stores
    }
    
}
