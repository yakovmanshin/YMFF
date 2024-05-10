//
//  CommonFeatureFlagStoreError.swift
//  YMFF
//
//  Created by Yakov Manshin on 5/7/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

enum CommonFeatureFlagStoreError: Error {
    case valueNotFound(key: String)
    case typeMismatch
}
