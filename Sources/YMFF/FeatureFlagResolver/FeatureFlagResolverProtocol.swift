//
//  FeatureFlagResolverProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

protocol FeatureFlagResolverProtocol {
    
    var configuration: FeatureFlagResolverConfigurationProtocol { get }
    
    func value<Value>(for key: FeatureFlagKey) -> Value?
    
}
