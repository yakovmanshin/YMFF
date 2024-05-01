//
//  FeatureFlagResolverConfiguration.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - FeatureFlagResolverConfiguration

/// The object used to configure the resolver.
final public class FeatureFlagResolverConfiguration {
    
    public var stores: [any FeatureFlagStoreProtocol]
    
    /// Initializes a new configuration with the given array of feature flag stores.
    public init(stores: [any FeatureFlagStoreProtocol]) {
        self.stores = stores
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
