//
//  FeatureFlagResolverConfigurationProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// An object that provides the resources critical to functioning of the resolver.
public protocol FeatureFlagResolverConfigurationProtocol {
    
    /// An array of stores which may contain feature flag values.
    ///
    /// + The stores are examined in order. The first value found for a key will be used.
    var persistentStores: [FeatureFlagStoreProtocol] { get }
    
    /// An object that provides feature flag values used in the runtime, within a single app session.
    var runtimeStore: MutableFeatureFlagStoreProtocol { get }
    
}
