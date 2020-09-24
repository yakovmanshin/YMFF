//
//  FeatureFlagResolver.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagResolver

final public class FeatureFlagResolver {
    
    // MARK: Properties
    
    let configuration: FeatureFlagResolverConfigurationProtocol
    
    // MARK: Initializers
    
    public init(configuration: FeatureFlagResolverConfiguration) {
        self.configuration = configuration
    }
    
}

// MARK: Value Resolution

extension FeatureFlagResolver {
    
    func retrieveValue(forKey key: String, from store: FeatureFlagStoreProtocol) throws -> Any {
        guard let value = store.value(forKey: key) else { throw FeatureFlagResolverError.valueNotFound }
        return value
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
