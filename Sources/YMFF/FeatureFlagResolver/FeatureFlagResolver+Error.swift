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
        
        /// The resolver doesn’t have any feature-flag stores suitable for the operation you’re trying to perform.
        ///
        /// + This error may occur if you’re trying to write a value while not having any mutable stores,
        /// or if you’re trying to synchronously read a value while having only asynchronous stores.
        case noStoreAvailable
        
        /// No feature-flag store contains a value for the given key.
        case valueNotFoundInStores(key: String)
        
        /// The feature-flag store has thrown an error.
        case storeError(any Swift.Error)
        
        /// Currently, optional values are not supported by the `FeatureFlagResolver`.
        ///
        /// - Note: Support for optional values will be added in [#130](https://github.com/yakovmanshin/YMFF/issues/130).
        case optionalValuesNotAllowed
        
    }
    
}
