//
//  AsyncMutableFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol AsyncMutableFeatureFlagStoreProtocol: AnyObject, AsyncFeatureFlagStoreProtocol {
    
    func setValue<Value>(_ value: Value, forKey key: String) async throws
    
    func removeValue(forKey key: String) async throws
    
    func saveChanges() async throws
    
}

// MARK: - Default Implementation

extension AsyncMutableFeatureFlagStoreProtocol {
    
    public func saveChanges() async throws { }
    
}
