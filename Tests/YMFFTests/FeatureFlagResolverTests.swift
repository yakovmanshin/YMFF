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
    
    func test_deinit() async throws {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .mutable(store2)]
        
        configuration = nil
        resolver = nil
        
        try await Task.sleep(nanoseconds: 1_000_000)
        
        XCTAssertEqual(store1.saveChanges_invocationCount, 1)
        XCTAssertEqual(store2.saveChangesSync_invocationCount, 1)
    }
    
}
