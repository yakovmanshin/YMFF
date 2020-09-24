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

// MARK: - Integrated Tests

extension FeatureFlagResolverTests {
    
    // MARK: Int Values
    
    func testIntValueResolution() {
        let expectedValue = 123
        
        XCTAssertEqual(try resolveIntValue(for: Constants.intKey), expectedValue)
    }
    
    private func resolveIntValue(for key: FeatureFlagKey) throws -> Int {
        try resolver._value(for: key)
    }
    
    // MARK: String Values
    
    func testStringValueResolution() {
        let expectedValue = "STRING_VALUE_REMOTE"
        
        XCTAssertEqual(try resolveStringValue(for: Constants.stringKey), expectedValue)
    }
    
    private func resolveStringValue(for key: FeatureFlagKey) throws -> String {
        try resolver._value(for: key)
    }
    
    // MARK: Optional Values
    
    func testOptionalIntNilValueResolution() {
        do {
            _ = try resolveOptionalValue(for: Constants.optionalIntNilKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    func testOptionalIntNonNilValueResolution() {
        do {
            _ = try resolveOptionalValue(for: Constants.optionalIntNonNilKey)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    private func resolveOptionalValue(for key: FeatureFlagKey) throws -> Int? {
        try resolver._value(for: key)
    }
    
    // MARK: Nonexistent Values

    func testNonexistentValueResolution() throws {
        do {
            _ = try resolveNonexistentValue(for: Constants.nonexistentKey)
            XCTFail()
        } catch FeatureFlagResolverError.valueNotFound { } catch { XCTFail() }
    }
    
    private func resolveNonexistentValue(for key: FeatureFlagKey) throws -> Int {
        try resolver._value(for: key)
    }
    
    // MARK: Value Type Casting
    
    func testValueTypeCasting() {
        do {
            _ = try resolveStringValue(for: Constants.intKey)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
    }
    
}

// MARK: - Units

extension FeatureFlagResolverTests {
    
    // MARK: Value Retrieval
    
    func testValueRetrieval() {
        let key = "int"
        let localStore = resolver.configuration.localStore
        let remoteStore = resolver.configuration.remoteStore
        
        XCTAssertNoThrow(try resolver.retrieveValue(forKey: key, from: localStore))
        
        do {
            _ = try resolver.retrieveValue(forKey: key, from: remoteStore)
            XCTFail()
        } catch FeatureFlagResolverError.valueNotFound { } catch { XCTFail() }
    }
    
    // MARK: Value Validation
    
    func testValueValidation() {
        let nonOptionalValue = 123
        let optionalValue: Int? = 123
        
        XCTAssertNoThrow(try resolver.validateValue(nonOptionalValue))
        
        do {
            _ = try resolver.validateValue(optionalValue as Any)
            XCTFail()
        } catch FeatureFlagResolverError.optionalValuesNotAllowed { } catch { XCTFail() }
    }
    
    // MARK: Optionality Check
    
    func testIfValueIsOptional() {
        let nonOptionalValue = 123
        let optionalValue: Int? = 123
        
        XCTAssertFalse(resolver.valueIsOptional(nonOptionalValue))
        XCTAssertTrue(resolver.valueIsOptional(optionalValue as Any))
    }
    
    // MARK: Value Type Casting
    
    func testValueTypeCastingSuccess() {
        let int = 123
        let intAsAny = int as Any
        let targetType = Int.self
        
        XCTAssertEqual(try resolver.cast(intAsAny, to: targetType), int)
    }
    
    func testValueTypeCastingFailure() {
        let int = 123
        let intAsAny = int as Any
        let targetType = String.self
        
        do {
            _ = try resolver.cast(intAsAny, to: targetType)
            XCTFail()
        } catch FeatureFlagResolverError.typeMismatch { } catch { XCTFail() }
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
