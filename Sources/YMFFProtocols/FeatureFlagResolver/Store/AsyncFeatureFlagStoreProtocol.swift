//
//  AsyncFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol AsyncFeatureFlagStoreProtocol {
    
    func value<Value>(forKey key: String) async throws -> Value
    
}
