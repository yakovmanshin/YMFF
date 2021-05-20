//
//  FeatureFlagResolverConfigurationTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 5/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest

@testable import YMFF

final class FeatureFlagResolverConfigurationTests: XCTestCase {
    
    func testStoreAdditionToMutableConfiguration() {
        let configuration = MutableFeatureFlagResolverConfiguration(stores: [])
        
        XCTAssertEqual(configuration.stores.count, 0)
        
        configuration.stores.append(.immutable(TransparentFeatureFlagStore()))
        
        XCTAssertEqual(configuration.stores.count, 1)
    }
    
    func testStoreRemovalFromMutableConfiguration() {
        let configuration = MutableFeatureFlagResolverConfiguration(stores: [.immutable(TransparentFeatureFlagStore())])
        
        XCTAssertEqual(configuration.stores.count, 1)
        
        configuration.stores.removeAll()
        
        XCTAssertEqual(configuration.stores.count, 0)
    }
    
}
