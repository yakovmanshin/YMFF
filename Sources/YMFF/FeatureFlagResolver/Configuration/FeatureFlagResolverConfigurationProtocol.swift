//
//  FeatureFlagResolverConfigurationProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that provides the resources critical to functioning of the resolver.
public protocol FeatureFlagResolverConfigurationProtocol {
    
    /// An object that provides feature flag values used as a fallback, when the remote store is not available.
    var localStore: FeatureFlagStoreProtocol { get }
    
    /// An object that provides feature flag values received from a remote server. This is the primary source of feature flag values.
    var remoteStore: FeatureFlagStoreProtocol { get }
    
    /// An object that provides feature flag values used in the runtime, within a single app session.
    var runtimeStore: MutableFeatureFlagStoreProtocol { get }
    
}
