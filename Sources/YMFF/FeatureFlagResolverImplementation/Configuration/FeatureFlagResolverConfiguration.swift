//
//  FeatureFlagResolverConfiguration.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagResolverConfiguration

public struct FeatureFlagResolverConfiguration {
    
    let localStore: FeatureFlagStoreProtocol
    let remoteStore: FeatureFlagStoreProtocol
    
    public init(localStore: FeatureFlagStore, remoteStore: FeatureFlagStore) {
        self.localStore = localStore
        self.remoteStore = remoteStore
    }
    
}

// MARK: - FeatureFlagResolverConfigurationProtocol

extension FeatureFlagResolverConfiguration: FeatureFlagResolverConfigurationProtocol { }
