//
//  FeatureFlagResolver.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

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
    
    public func value<Value>(for key: FeatureFlagKey) -> Value? {
        try? _value(for: key)
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
    
    func _value<Value>(for key: FeatureFlagKey) throws -> Value {
        let anyValueCandidate: Any
        let expectedType = Value.self
        let valueCandidate: Value
        
        if let anyRuntimeValue = try? retrieveValue(forKey: key, from: configuration.runtimeStore) {
            anyValueCandidate = anyRuntimeValue
        } else {
            let anyPersistentValue = try retrieveValueFromFirstStore(of: configuration.persistentStores, containingKey: key)
            anyValueCandidate = anyPersistentValue
        }
        
        try validateValue(anyValueCandidate)
        
        valueCandidate = try cast(anyValueCandidate, to: expectedType)
        
        return valueCandidate
    }
    
    func retrieveValue(forKey key: String, from store: FeatureFlagStoreProtocol) throws -> Any {
        guard let value: Any = store.value(forKey: key) else { throw FeatureFlagResolverError.valueNotFoundInSpecificStore }
        return value
    }
    
    func retrieveValueFromFirstStore(of stores: [FeatureFlagStoreProtocol], containingKey key: String) throws -> Any {
        guard !stores.isEmpty else { throw FeatureFlagResolverError.persistentStoresIsEmpty }
        
        for store in stores {
            if let value: Any = store.value(forKey: key) {
                return value
            }
        }
        
        throw FeatureFlagResolverError.noStoreContainsValueForKey
    }
    
    func validateValue(_ value: Any) throws {
        if valueIsOptional(value) {
            throw FeatureFlagResolverError.optionalValuesNotAllowed
        }
    }
    
    func valueIsOptional(_ value: Any) -> Bool {
        value is ExpressibleByNilLiteral
    }
    
    func cast<T>(_ anyValue: Any, to expectedType: T.Type) throws -> T {
        guard let value = anyValue as? T else { throw FeatureFlagResolverError.typeMismatch }
        return value
    }
    
}

// MARK: - Runtime Overriding

extension FeatureFlagResolver {
    
    func validateOverrideValue<Value>(_ value: Value, forKey key: FeatureFlagKey) throws {
        try validateValue(value)
        
        let anyPersistentValue = try? retrieveValueFromFirstStore(of: configuration.persistentStores, containingKey: key)
        
        if let anyPersistentValue = anyPersistentValue {
            _ = try cast(anyPersistentValue, to: Value.self)
        }
    }
    
}
