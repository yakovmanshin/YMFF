//
//  FeatureFlagResolver.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - FeatureFlagResolver

/// A concrete, YMFF-supplied implementation of the feature flag resolver.
final public class FeatureFlagResolver {
    
    // MARK: Properties
    
    public let configuration: FeatureFlagResolverConfigurationProtocol
    
    // MARK: Initializers
    
    public init(configuration: FeatureFlagResolverConfigurationProtocol) {
        self.configuration = configuration
    }
    
    @available(*, deprecated, message: "Use init(stores:)")
    public convenience init(configuration: FeatureFlagResolverConfiguration) {
        self.init(configuration: configuration as FeatureFlagResolverConfigurationProtocol)
    }
    
    deinit {
        configuration.stores
            .compactMap({ $0.asMutable })
            .forEach({ $0.saveChanges() })
    }
    
}

// MARK: - FeatureFlagResolverProtocol

extension FeatureFlagResolver: FeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) throws -> Value {
        let retrievedValue: Value = try retrieveFirstValueFoundInStores(byKey: key)
        try validateValue(retrievedValue)
        
        return retrievedValue
    }
    
    public func setValue<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) throws {
        try validateOverrideValue(newValue, forKey: key)
        
        let mutableStore = try findMutableStores()[0]
        mutableStore.setValue(newValue, forKey: key)
    }
    
    public func removeValueFromMutableStore(using key: FeatureFlagKey) throws {
        let mutableStore = try firstMutableStore(withValueForKey: key)
        mutableStore.removeValue(forKey: key)
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
    
    private func firstMutableStore(withValueForKey key: String) throws -> MutableFeatureFlagStoreProtocol {
        let mutableStores = try findMutableStores()
        
        guard let firstStoreWithValueForKey = mutableStores.first(where: { $0.containsValue(forKey: key) }) else {
            throw FeatureFlagResolverError.noMutableStoreContainsValueForKey(key: key)
        }
        return firstStoreWithValueForKey
    }
    
    private func findMutableStores() throws -> [MutableFeatureFlagStoreProtocol] {
        let stores = configuration.stores.compactMap({ $0.asMutable })
        
        if stores.isEmpty {
            throw FeatureFlagResolverError.noMutableStoreAvailable
        }
        
        return stores
    }
    
}
