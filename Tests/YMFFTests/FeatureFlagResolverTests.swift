//
//  FeatureFlagResolverTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/24/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

import XCTest
@testable import YMFF

// MARK: - Configuration

final class FeatureFlagResolverTests: XCTestCase {
    
    private var resolver: FeatureFlagResolver!
    
    override func setUp() {
        super.setUp()
        
        resolver = FeatureFlagResolver(configuration: Constants.configuration)
    }
    
}

// MARK: - Constants

extension FeatureFlagResolverTests {
    
    private enum Constants {
        
        static var configuration = FeatureFlagResolverConfiguration(
            localStore: .transparent(localStore),
            remoteStore: .transparent(remoteStore)
        )
        
        private static var localStore: [String : Any] { [
            "int": 123,
            "string": "STRING_VALUE_LOCAL",
            "optionalIntNonNil": Optional<Int>.some(123) as Any
        ] }
        
        private static var remoteStore: [String : Any] { [
            "string": "STRING_VALUE_REMOTE",
            "optionalIntNil": Optional<Int>.none as Any,
            "optionalIntNonNil": Optional<Int>.some(456) as Any
        ] }
        
        static var intKey: FeatureFlagKey { .init("int") }
        static var stringKey: FeatureFlagKey { .init("string") }
        static var optionalIntNilKey: FeatureFlagKey { .init("optionalIntNil") }
        static var optionalIntNonNilKey: FeatureFlagKey { .init("optionalIntNonNil") }
        static var nonexistentKey: FeatureFlagKey { .init("nonexistent") }
        
    }
    
}
