//
//  FeatureFlagKeyTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

final class FeatureFlagKeyTests: XCTestCase {
    
    func testUniversalKeyInitializer() {
        let keyString = "TEST_KEY"
        
        let featureFlagKey = FeatureFlagKey(keyString)
        
        XCTAssertEqual(featureFlagKey.remoteKey, keyString)
    }
    
}
