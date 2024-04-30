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
    
    public func value<Value>(for key: FeatureFlagKey) async throws -> Value {
        let retrievedValue: Value = try await retrieveFirstValue(forKey: key)
        try validateValue(retrievedValue)
        
        return retrievedValue
    }
    
    public func setValue<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) async throws {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw FeatureFlagResolverError.noMutableStoreAvailable
        }
        
        try await validateOverrideValue(newValue, forKey: key)
        
        await mutableStores[0].setValue(newValue, forKey: key)
    }
    
    public func removeValueFromMutableStore(using key: FeatureFlagKey) async throws {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw FeatureFlagResolverError.noMutableStoreAvailable
        }
        
        await mutableStores[0].removeValue(forKey: key)
    }
    
}

// MARK: - SynchronousFeatureFlagResolverProtocol

extension FeatureFlagResolver: SynchronousFeatureFlagResolverProtocol {
    
    public func valueSync<Value>(for key: FeatureFlagKey) throws -> Value {
        let retrievedValue: Value = try retrieveFirstValueSync(forKey: key)
        try validateValue(retrievedValue)
        
        return retrievedValue
    }
    
    public func setValueSync<Value>(_ newValue: Value, toMutableStoreUsing key: FeatureFlagKey) throws {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        guard !getSyncStores().isEmpty else {
            throw FeatureFlagResolverError.noSyncStoreAvailable
        }
        
        let mutableStores = getSyncMutableStores()
        guard !mutableStores.isEmpty else {
            throw FeatureFlagResolverError.noSyncMutableStoreAvailable
        }
        
        try validateOverrideValueSync(newValue, forKey: key)
        
        mutableStores[0].setValueSync(newValue, forKey: key)
    }
    
    public func removeValueFromMutableStoreSync(using key: FeatureFlagKey) throws {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        guard !getSyncStores().isEmpty else {
            throw FeatureFlagResolverError.noSyncStoreAvailable
        }
        
        let mutableStores = getSyncMutableStores()
        guard !mutableStores.isEmpty else {
            throw FeatureFlagResolverError.noSyncMutableStoreAvailable
        }
        
        mutableStores[0].removeValueSync(forKey: key)
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
    
    private func retrieveFirstValue<Value>(forKey key: String) async throws -> Value {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        let matchingStores = getStores()
        
        for store in matchingStores {
            if await store.containsValue(forKey: key) {
                guard let value: Value = await store.value(forKey: key)
                else { throw FeatureFlagResolverError.typeMismatch }
                
                return value
            }
        }
        
        throw FeatureFlagResolverError.valueNotFoundInPersistentStores(key: key)
    }
    
    private func retrieveFirstValueSync<Value>(forKey key: String) throws -> Value {
        guard !configuration.stores.isEmpty else {
            throw FeatureFlagResolverError.noStoreAvailable
        }
        
        let matchingStores = getSyncStores()
        guard !matchingStores.isEmpty else {
            throw FeatureFlagResolverError.noSyncStoreAvailable
        }
        
        for store in matchingStores {
            if store.containsValueSync(forKey: key) {
                guard let value: Value = store.valueSync(forKey: key)
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
    
    private func validateOverrideValue<Value>(_ value: Value, forKey key: FeatureFlagKey) async throws {
        try validateValue(value)
        
        do {
            let _: Value = try await retrieveFirstValue(forKey: key)
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores {
            // If none of the persistent stores contains a value for the key, then the client is attempting
            // to set a new value (instead of overriding an existing one). That’s an acceptable use case.
        } catch {
            throw error
        }
    }
    
    func validateOverrideValueSync<Value>(_ value: Value, forKey key: FeatureFlagKey) throws {
        try validateValue(value)
        
        do {
            let _: Value = try retrieveFirstValueSync(forKey: key)
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores {
            // If none of the persistent stores contains a value for the key, then the client is attempting
            // to set a new value (instead of overriding an existing one). That’s an acceptable use case.
        } catch {
            throw error
        }
    }
    
}
