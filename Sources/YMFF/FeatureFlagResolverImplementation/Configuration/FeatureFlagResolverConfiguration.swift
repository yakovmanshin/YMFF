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
    
    public let localStore: FeatureFlagStoreProtocol
    public let remoteStore: FeatureFlagStoreProtocol
    public let runtimeStore: MutableFeatureFlagStoreProtocol
    
    public init(
        localStore: FeatureFlagStore,
        remoteStore: FeatureFlagStore,
        runtimeStore: MutableFeatureFlagStoreProtocol
    ) {
        self.localStore = localStore
        self.remoteStore = remoteStore
        self.runtimeStore = runtimeStore
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
