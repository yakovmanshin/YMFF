//
//  FeatureFlagValueTransformerTests.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 2/5/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest

// MARK: - Tests

final class FeatureFlagValueTransformerTests: XCTestCase {
    
    func test_valueFromRawValue_identityTransformer() {
        let transformer = FeatureFlagValueTransformer<Int, Int>.identity
        
        let value = transformer.valueFromRawValue(123)
        
        XCTAssertEqual(value, 123)
    }
    
    func test_rawValueFromValue_identityTransformer() {
        let transformer = FeatureFlagValueTransformer<String, String>.identity
        
        let rawValue = transformer.rawValueFromValue("TEST_value")
        
        XCTAssertEqual(rawValue, "TEST_value")
    }
    
    func test_valueFromRawValue_sameType() {
        let transformer = FeatureFlagValueTransformer { rawValue in
            String(rawValue.dropFirst(4))
        } rawValueFromValue: { value in
            "RAW_\(value)"
        }
        
        let value = transformer.valueFromRawValue("RAW_some_value")
        
        XCTAssertEqual(value, "some_value")
    }
    
    func test_rawValueFromValue_sameType() {
        let transformer = FeatureFlagValueTransformer { rawValue in
            rawValue / 2
        } rawValueFromValue: { value in
            value * 2
        }
        
        let rawValue = transformer.rawValueFromValue(123)
        
        XCTAssertEqual(rawValue, 246)
    }
    
    func test_valueFromRawValue_intFromString() {
        let transformer = FeatureFlagValueTransformer { string in
            Int(string)
        } rawValueFromValue: { int in
            "\(int)"
        }
        
        let value = transformer.valueFromRawValue("12345")
        
        XCTAssertEqual(value, 12345)
    }
    
    func test_rawValueFromValue_stringFromBool() {
        let transformer = FeatureFlagValueTransformer { string in
            string == "YES"
        } rawValueFromValue: { bool in
            bool ? "YES" : "NO"
        }
        
        let rawValue = transformer.rawValueFromValue(true)
        
        XCTAssertEqual(rawValue, "YES")
    }
    
    func test_valueFromRawValue_enumFromInt() {
        let transformer = FeatureFlagValueTransformer { (age: Int) -> AgeGroup in
            switch age {
            case ..<13: .under13
            case 13...17: .between13And17
            case 18...: .over17
            default: .under13
            }
        } rawValueFromValue: { group in
            switch group {
            case .under13: 13
            case .between13And17: 17
            case .over17: 18
            }
        }
        
        let intRawValue5 = 5
        let intRawValue15 = 15
        let intRawValue20 = 20
        
        XCTAssertEqual(transformer.valueFromRawValue(intRawValue5), .under13)
        XCTAssertEqual(transformer.valueFromRawValue(intRawValue15), .between13And17)
        XCTAssertEqual(transformer.valueFromRawValue(intRawValue20), .over17)
        
        XCTAssertEqual(transformer.rawValueFromValue(.under13), 13)
        XCTAssertEqual(transformer.rawValueFromValue(.between13And17), 17)
        XCTAssertEqual(transformer.rawValueFromValue(.over17), 18)
    }
    
    func test_rawValueFromValue_stringFromEnum() {
        let transformer = FeatureFlagValueTransformer { string in
            AdType(rawValue: string)
        } rawValueFromValue: { type in
            type.rawValue
        }
        
        let stringRawValueNone = "none"
        let stringRawValueBanner = "banner"
        let stringRawValueVideo = "video"
        let stringRawValueOther = "image"
        
        XCTAssertEqual(transformer.valueFromRawValue(stringRawValueNone), AdType.none)
        XCTAssertEqual(transformer.valueFromRawValue(stringRawValueBanner), .banner)
        XCTAssertEqual(transformer.valueFromRawValue(stringRawValueVideo), .video)
        XCTAssertEqual(transformer.valueFromRawValue(stringRawValueOther), nil)
        
        XCTAssertEqual(transformer.rawValueFromValue(.none), stringRawValueNone)
        XCTAssertEqual(transformer.rawValueFromValue(.banner), stringRawValueBanner)
        XCTAssertEqual(transformer.rawValueFromValue(.video), stringRawValueVideo)
    }
    
}

// MARK: - Support Types

fileprivate enum AdType: String {
    case none
    case banner
    case video
}

fileprivate enum AgeGroup {
    case under13
    case between13And17
    case over17
}
