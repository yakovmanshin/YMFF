//
//  FeatureFlagResolver+Configuration.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - Configuration

extension FeatureFlagResolver {
    
    /// The object used to configure the resolver.
    final public class Configuration {
        
        public var stores: [any FeatureFlagStore]
        
        /// Initializes a new configuration with the given array of feature flag stores.
        public init(stores: [any FeatureFlagStore]) {
            self.stores = stores
        }
        
    }
    
}


// MARK: - FeatureFlagResolverConfiguration

extension FeatureFlagResolver.Configuration: FeatureFlagResolverConfiguration { }
