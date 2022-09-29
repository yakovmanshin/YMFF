//
//  AsyncMutableStoreTests.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 9/30/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

final class AsyncMutableStoreTests: XCTestCase {
    
    private var asyncMutableStore: AsyncMutableFeatureFlagStoreProtocol!
    private var resolver: FeatureFlagResolverProtocol!
    
    override func setUp() async throws {
        try await super.setUp()
        
        asyncMutableStore = AsyncMutableFeatureFlagStoreMock(store: .init())
        resolver = FeatureFlagResolver(stores: [])
    }
    
}
