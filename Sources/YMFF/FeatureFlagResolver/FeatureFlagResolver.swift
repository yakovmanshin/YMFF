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

/// The concrete, YMFF-supplied implementation of the *synchronous* feature-flag resolver.
final public class FeatureFlagResolver {
    
    // MARK: Properties
    
    public let configuration: any FeatureFlagResolverConfiguration
    
    // MARK: Initializers
    
    /// Initializes the resolver with an object which conforms to `FeatureFlagResolverConfiguration`.
    ///
    /// - Parameter configuration: *Required.* The configuration used to read and write feature-flag values.
    public init(configuration: any FeatureFlagResolverConfiguration) {
        self.configuration = configuration
    }
    
    /// Initializes the resolver with an array of feature-flag stores.
    ///
    /// + Passing an empty array will result in a `noStoreAvailable` error on the next read attempt.
    ///
    /// - Parameter stores: *Required.* The array of feature-flag stores.
    public convenience init(stores: [any FeatureFlagStore]) {
        let configuration = Configuration(stores: stores)
        self.init(configuration: configuration)
    }
    
}

// MARK: - FeatureFlagResolverProtocol

extension FeatureFlagResolver: FeatureFlagResolverProtocol {
    
    public func value<Value>(for key: FeatureFlagKey) async throws -> Value {
        try await retrieveFirstValue(forKey: key)
    }
    
    public func setValue<Value>(_ value: Value, for key: FeatureFlagKey) async throws {
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        for store in getStores() {
            if
                case .failure(let error) = await store.value(for: key) as Result<Value, _>,
                case .typeMismatch = error
            {
                throw Error.storeError(error)
            }
        }
        
        var lastErrorFromStore: (any Swift.Error)?
        for store in mutableStores {
            do {
                try await store.setValue(value, for: key)
            } catch {
                lastErrorFromStore = error
            }
        }
        
        if let lastErrorFromStore {
            throw Error.storeError(lastErrorFromStore)
        }
    }
    
    public func removeValue(for key: FeatureFlagKey) async throws {
        let mutableStores = getMutableStores()
        guard !mutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        var lastErrorFromStore: (any Swift.Error)?
        for store in mutableStores {
            do {
                try await store.removeValue(for: key)
            } catch {
                lastErrorFromStore = error
            }
        }
        
        if let lastErrorFromStore {
            throw Error.storeError(lastErrorFromStore)
        }
    }
    
}

// MARK: - SynchronousFeatureFlagResolverProtocol

extension FeatureFlagResolver: SynchronousFeatureFlagResolverProtocol {
    
    public func valueSync<Value>(for key: FeatureFlagKey) throws -> Value {
        try retrieveFirstValueSync(forKey: key)
    }
    
    public func setValueSync<Value>(_ value: Value, for key: FeatureFlagKey) throws {
        let syncMutableStores = getSyncMutableStores()
        guard !syncMutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        for store in getSyncStores() {
            if
                case .failure(let error) = store.valueSync(for: key) as Result<Value, _>,
                case .typeMismatch = error
            {
                throw Error.storeError(error)
            }
        }
        
        var lastErrorFromStore: (any Swift.Error)?
        for store in syncMutableStores {
            do {
                try store.setValueSync(value, for: key)
            } catch {
                lastErrorFromStore = error
            }
        }
        
        if let lastErrorFromStore {
            throw Error.storeError(lastErrorFromStore)
        }
    }
    
    public func removeValueSync(for key: FeatureFlagKey) throws {
        let syncMutableStores = getSyncMutableStores()
        guard !syncMutableStores.isEmpty else {
            throw Error.noStoreAvailable
        }
        
        var lastErrorFromStore: (any Swift.Error)?
        for store in syncMutableStores {
            do {
                try store.removeValueSync(for: key)
            } catch {
                lastErrorFromStore = error
            }
        }
        
        if let lastErrorFromStore {
            throw Error.storeError(lastErrorFromStore)
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
            switch await store.value(for: key) as Result<Value, _> {
            case .success(let value):
                return value
            case .failure(let error):
                switch error {
                case .valueNotFound:
                    continue
                case .typeMismatch:
                    throw Error.storeError(error)
                case .otherError(let error):
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
            switch store.valueSync(for: key) as Result<Value, _> {
            case .success(let value):
                return value
            case .failure(let error):
                switch error {
                case .valueNotFound:
                    continue
                case .typeMismatch:
                    throw Error.storeError(error)
                case .otherError(let error):
                    throw Error.storeError(error)
                }
            }
        }
        
        throw Error.valueNotFoundInStores(key: key)
    }
    
}
