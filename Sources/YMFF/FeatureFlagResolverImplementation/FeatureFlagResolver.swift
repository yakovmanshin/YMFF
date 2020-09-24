//
//  FeatureFlagResolver.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

// MARK: - FeatureFlagResolver

final public class FeatureFlagResolver {
    
    // MARK: Properties
    
    let configuration: FeatureFlagResolverConfigurationProtocol
    
    // MARK: Initializers
    
    public init(configuration: FeatureFlagResolverConfiguration) {
        self.configuration = configuration
    }
    
}
