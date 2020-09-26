//
//  FeatureFlagResolverConfigurationProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

public protocol FeatureFlagResolverConfigurationProtocol {
    
    var localStore: FeatureFlagStoreProtocol { get }
    
    var remoteStore: FeatureFlagStoreProtocol { get }
    
    var runtimeStore: MutableFeatureFlagStoreProtocol { get }
    
}
