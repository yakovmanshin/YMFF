//
//  FeatureFlagResolverTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/24/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - Configuration

final class FeatureFlagResolverTests: XCTestCase {
    
    private var resolver: FeatureFlagResolver!
    
    private var configuration: FeatureFlagResolverConfigurationProtocol!
    
    override func setUp() {
        super.setUp()
        
        configuration = FeatureFlagResolverConfiguration(stores: [])
        resolver = FeatureFlagResolver(configuration: configuration)
    }
    
}
