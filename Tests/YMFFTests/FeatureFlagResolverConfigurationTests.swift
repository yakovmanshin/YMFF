//
//  FeatureFlagResolverConfigurationTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 5/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest

final class FeatureFlagResolverConfigurationTests: XCTestCase {
    
    func testStoreAdditionToConfiguration() {
        let configuration = FeatureFlagResolverConfiguration(stores: [])
        
        XCTAssertEqual(configuration.stores.count, 0)
        
        configuration.stores.append(.immutable(TransparentFeatureFlagStore()))
        
        XCTAssertEqual(configuration.stores.count, 1)
    }
    
    func testStoreRemovalFromConfiguration() {
        let configuration = FeatureFlagResolverConfiguration(stores: [.immutable(TransparentFeatureFlagStore())])
        
        XCTAssertEqual(configuration.stores.count, 1)
        
        configuration.stores.removeAll()
        
        XCTAssertEqual(configuration.stores.count, 0)
    }
    
}
