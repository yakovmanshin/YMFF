//
//  FeatureFlagStore.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 5/11/24.
//  Copyright © 2024 Yakov Manshin. See the LICENSE file for license info.
//

public enum FeatureFlagStoreError: Error {
    case valueNotFound
    case typeMismatch
    case otherError(any Error)
}
