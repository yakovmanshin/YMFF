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
    
    /// Initializes the resolver with an object that conforms to `FeatureFlagResolverConfigurationProtocol`.
    ///
    /// - Parameter configuration: *Required.* The configuration used to read and write feature flag values.
    public init(configuration: FeatureFlagResolverConfigurationProtocol) {
        self.configuration = configuration
    }
    
    /// Initializes the resolver with the list of feature flag stores.
    ///
    /// + Passing in an empty array will produce the `noStoreAvailable` error on next read attempt.
    ///
    /// - Parameter stores: *Required.* The array of feature flag stores.
    public convenience init(stores: [FeatureFlagStore]) {
        let configuration: FeatureFlagResolverConfigurationProtocol = FeatureFlagResolverConfiguration(stores: stores)
        self.init(configuration: configuration)
    }
    
    deinit {
        let mutableStores = getMutableStores()
        Task { [mutableStores] in
            for store in mutableStores {
                await store.saveChanges()
            }
        }
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

// MARK: - Stores

extension FeatureFlagResolver {
    
    private func getStores() -> [any FeatureFlagStoreProtocol] {
        configuration.stores.map { $0.asImmutable }
    }
    
    private func getSyncStores() -> [any SynchronousFeatureFlagStoreProtocol] {
        getStores().compactMap { $0 as? SynchronousFeatureFlagStoreProtocol }
    }
    
    private func getMutableStores() -> [any MutableFeatureFlagStoreProtocol] {
        getStores().compactMap { $0 as? MutableFeatureFlagStoreProtocol }
    }
    
    private func getSyncMutableStores() -> [any SynchronousMutableFeatureFlagStoreProtocol] {
        getStores().compactMap { $0 as? SynchronousMutableFeatureFlagStoreProtocol }
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
