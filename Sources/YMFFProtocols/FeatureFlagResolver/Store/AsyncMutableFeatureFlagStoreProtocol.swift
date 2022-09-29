//
//  AsyncMutableFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

#if swift(>=5.5)

@available(iOS 13, *)
@available(macOS 10.15, *)
public protocol AsyncMutableFeatureFlagStoreProtocol: AnyObject, AsyncFeatureFlagStoreProtocol {
    
    func setValue<Value>(_ value: Value, forKey key: String) async throws
    
    func removeValue(forKey key: String) async throws
    
    func saveChanges() async throws
    
}

// MARK: - Default Implementation

@available(iOS 13, *)
@available(macOS 10.15, *)
extension AsyncMutableFeatureFlagStoreProtocol {
    
    public func saveChanges() async throws { }
    
}

#endif
