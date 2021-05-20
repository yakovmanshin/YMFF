//
//  MutableFeatureFlagResolverConfiguration.swift
//  YMFF
//
//  Created by Yakov Manshin on 5/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - MutableFeatureFlagResolverConfiguration

/// An object used to configure the resolver, which holds feature flag stores that can be changed.
final public class MutableFeatureFlagResolverConfiguration {
    
    public var stores: [FeatureFlagStore]
    
    public init(stores: [FeatureFlagStore]) {
        self.stores = stores
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension MutableFeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
