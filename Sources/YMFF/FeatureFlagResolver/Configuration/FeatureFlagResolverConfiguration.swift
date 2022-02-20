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

/// An object used to configure the resolver.
final public class FeatureFlagResolverConfiguration {
    
    public var stores: [FeatureFlagStore]
    
    /// Initializes a new configuration with the given array of feature flag stores.
    public init(stores: [FeatureFlagStore]) {
        self.stores = stores
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
