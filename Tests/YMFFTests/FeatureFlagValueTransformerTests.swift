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
    
    func testIdentityTransformer() {
        let transformer: FeatureFlagValueTransformer<Int, Int> = .identity
        
        let intValue = 123
        
        XCTAssertEqual(transformer.valueFromRawValue(intValue), intValue)
        XCTAssertEqual(transformer.rawValueFromValue(intValue), intValue)
    }
    
    func testSameTypeTransformation() {
        let transformer = FeatureFlagValueTransformer { string in
            String(string.dropFirst(4))
        } rawValueFromValue: { string in
            "RAW_\(string)"
        }
        
        let stringValue = "some_value"
        let stringRawValue = "RAW_some_value"
        
        XCTAssertEqual(transformer.valueFromRawValue(stringRawValue), stringValue)
        XCTAssertEqual(transformer.rawValueFromValue(stringValue), stringRawValue)
    }
    
    func testStringToBoolTransformation() {
        let transformer = FeatureFlagValueTransformer { string in
            string == "true"
        } rawValueFromValue: { bool in
            bool ? "true" : "false"
        }
        
        let stringRawValueTrue = "true"
        let stringRawValueFalse = "false"
        let stringRawValueOther = "OTHER"
        
        XCTAssertTrue(transformer.valueFromRawValue(stringRawValueTrue) == true)
        XCTAssertTrue(transformer.valueFromRawValue(stringRawValueFalse) == false)
        XCTAssertTrue(transformer.valueFromRawValue(stringRawValueOther) == false)
        
        XCTAssertEqual(transformer.rawValueFromValue(true), stringRawValueTrue)
        XCTAssertEqual(transformer.rawValueFromValue(false), stringRawValueFalse)
    }
    
    func testStringToEnumWithRawValueTransformation() {
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
    
    func testIntToEnumWithCustomInitializationTransformation() {
        let transformer = FeatureFlagValueTransformer { (age: Int) -> AgeGroup in
            switch age {
            case ..<13:
                return .under13
            case 13...17:
                return .between13And17
            case 18...:
                return .over17
            default:
                return .under13
            }
        } rawValueFromValue: { group in
            switch group {
            case .under13:
                return 13
            case .between13And17:
                return 17
            case .over17:
                return 18
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
