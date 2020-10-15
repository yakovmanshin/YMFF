//
//  FeatureFlagResolverConfiguration.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagResolverConfiguration

/// A YMFF-supplied object used to provide the feature flag resolver with its configuration.
public struct FeatureFlagResolverConfiguration {
    
    public let persistentStores: [FeatureFlagStoreProtocol]
    public let runtimeStore: MutableFeatureFlagStoreProtocol
    
    public init(
        persistentStores: [FeatureFlagStore],
        runtimeStore: MutableFeatureFlagStoreProtocol = RuntimeOverridesStore()
    ) {
        self.persistentStores = persistentStores
        self.runtimeStore = runtimeStore
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
