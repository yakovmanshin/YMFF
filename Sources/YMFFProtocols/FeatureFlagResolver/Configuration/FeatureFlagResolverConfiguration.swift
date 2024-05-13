//
//  FeatureFlagResolverConfiguration.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// The object which provides the resources crucial to the functioning of the resolver.
public protocol FeatureFlagResolverConfiguration: AnyObject {
    
    /// An array of stores which contain feature-flag values.
    var stores: [any FeatureFlagStore] { get set }
    
}
