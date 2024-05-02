//
//  FeatureFlagResolver+Error.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

extension FeatureFlagResolver {
    
    /// Errors returned by `FeatureFlagResolver`.
    public enum Error: Swift.Error {
        case noStoreAvailable
        case valueNotFoundInStores(key: String)
        case optionalValuesNotAllowed
        case typeMismatch
    }
    
}
