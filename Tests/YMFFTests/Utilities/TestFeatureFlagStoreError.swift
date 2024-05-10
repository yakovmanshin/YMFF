//
//  TestFeatureFlagStoreError.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 5/10/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

enum TestFeatureFlagStoreError: Error, Equatable {
    case failedToSetValue
    case failedToRemoveValue
}
