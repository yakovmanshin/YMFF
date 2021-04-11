//
//  FeatureFlagResolverConfiguration.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import YMFFProtocols

// MARK: - FeatureFlagResolverConfiguration

/// A YMFF-supplied object used to provide the feature flag resolver with its configuration.
public struct FeatureFlagResolverConfiguration {
    
    public let stores: [YMFFProtocols.FeatureFlagStore]
    
    public init(stores: [YMFFProtocols.FeatureFlagStore]) {
        self.stores = stores
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
