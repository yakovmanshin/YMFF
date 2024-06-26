//
//  FeatureFlagResolverConfigurationTests.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 5/17/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest

final class FeatureFlagResolverConfigurationTests: XCTestCase {
    
    func testStoreAdditionToConfiguration() {
        let configuration = FeatureFlagResolver.Configuration(stores: [])
        
        XCTAssertEqual(configuration.stores.count, 0)
        
        configuration.stores.append(TransparentFeatureFlagStore())
        
        XCTAssertEqual(configuration.stores.count, 1)
    }
    
    func testStoreRemovalFromConfiguration() {
        let configuration = FeatureFlagResolver.Configuration(stores: [TransparentFeatureFlagStore()])
        
        XCTAssertEqual(configuration.stores.count, 1)
        
        configuration.stores.removeAll()
        
        XCTAssertEqual(configuration.stores.count, 0)
    }
    
}
