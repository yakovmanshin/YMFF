//
//  FeatureFlagResolverError.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/20/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

/// Errors returned by `FeatureFlagResolver`.
public enum FeatureFlagResolverError: Error {
    case noMutableStoreAvailable
    case noMutableStoreContainsValueForKey(key: String)
    case noStoreAvailable
    case optionalValuesNotAllowed
    case typeMismatch
    case valueNotFoundInPersistentStores(key: String)
}
