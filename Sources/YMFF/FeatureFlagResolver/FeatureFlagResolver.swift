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
    
    public let configuration: any FeatureFlagResolverConfiguration
    
    // MARK: Initializers
    
    /// Initializes the resolver with an object that conforms to `FeatureFlagResolverConfiguration`.
    ///
    /// - Parameter configuration: *Required.* The configuration used to read and write feature flag values.
    public init(configuration: any FeatureFlagResolverConfiguration) {
        self.configuration = configuration
    }
    
    /// Initializes the resolver with the list of feature flag stores.
    ///
    /// + Passing in an empty array will produce the `noStoreAvailable` error on next read attempt.
    ///
    /// - Parameter stores: *Required.* The array of feature flag stores.
    public convenience init(stores: [any FeatureFlagStore]) {
        let configuration: any FeatureFlagResolverConfiguration = Configuration(stores: stores)
        self.init(configuration: configuration)
    }
    
    deinit {
        let mutableStores = getMutableStores()
        Task { [mutableStores] in
            for store in mutableStores {
                try? await store.saveChanges()
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
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        try await validateOverrideValue(newValue, forKey: key)
        
        do {
            try await mutableStores[0].setValue(newValue, forKey: key)
        } catch {
            throw Error.storeError(error)
        }
    }
    
    public func removeValueFromMutableStore(using key: FeatureFlagKey) async throws {
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        do {
            try await mutableStores[0].removeValue(forKey: key)
        } catch {
            throw Error.storeError(error)
        }
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
        let syncMutableStores = getSyncMutableStores()
        guard !syncMutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        try validateOverrideValueSync(newValue, forKey: key)
        
        do {
            try syncMutableStores[0].setValueSync(newValue, forKey: key)
        } catch {
            throw Error.storeError(error)
        }
    }
    
    public func removeValueFromMutableStoreSync(using key: FeatureFlagKey) throws {
        let syncMutableStores = getSyncMutableStores()
        guard !syncMutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        do {
            try syncMutableStores[0].removeValueSync(forKey: key)
        } catch {
            throw Error.storeError(error)
        }
    }
    
}

// MARK: - Stores

extension FeatureFlagResolver {
    
    private func getStores() -> [any FeatureFlagStore] {
        configuration.stores
    }
    
    private func getSyncStores() -> [any SynchronousFeatureFlagStore] {
        getStores().compactMap { $0 as? SynchronousFeatureFlagStore }
    }
    
    private func getMutableStores() -> [any MutableFeatureFlagStore] {
        getStores().compactMap { $0 as? MutableFeatureFlagStore }
    }
    
    private func getSyncMutableStores() -> [any SynchronousMutableFeatureFlagStore] {
        getStores().compactMap { $0 as? SynchronousMutableFeatureFlagStore }
    }
    
}

// MARK: Value Resolution

extension FeatureFlagResolver {
    
    private func retrieveFirstValue<Value>(forKey key: String) async throws -> Value {
        let matchingStores = getStores()
        guard !matchingStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        for store in matchingStores {
            if await store.containsValue(forKey: key) {
                do {
                    let value: Value = try await store.value(forKey: key)
                    return value
                } catch {
                    throw Error.storeError(error)
                }
            }
        }
        
        throw Error.valueNotFoundInStores(key: key)
    }
    
    private func retrieveFirstValueSync<Value>(forKey key: String) throws -> Value {
        let matchingStores = getSyncStores()
        guard !matchingStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        for store in matchingStores {
            if store.containsValueSync(forKey: key) {
                do {
                    let value: Value = try store.valueSync(forKey: key)
                    return value
                } catch {
                    throw Error.storeError(error)
                }
            }
        }
        
        throw Error.valueNotFoundInStores(key: key)
    }
    
    func validateValue<Value>(_ value: Value) throws {
        if valueIsOptional(value) {
            throw Error.optionalValuesNotAllowed
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
        } catch Error.valueNotFoundInStores {
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
        } catch Error.valueNotFoundInStores {
            // If none of the persistent stores contains a value for the key, then the client is attempting
            // to set a new value (instead of overriding an existing one). That’s an acceptable use case.
        } catch {
            throw error
        }
    }
    
}
