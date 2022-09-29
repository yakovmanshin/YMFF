//
//  AsyncMutableFeatureFlagStoreMock.swift
//  YMFFTests
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

#if swift(>=5.5)

import YMFF
#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - Mock

final class AsyncMutableFeatureFlagStoreMock: AsyncMutableFeatureFlagStoreProtocol {
    
    private var store: TransparentFeatureFlagStore
    private var onSaveChangesClosure: () -> Void
    
    init(store: TransparentFeatureFlagStore, onSaveChanges: @escaping () -> Void = { }) {
        self.store = store
        self.onSaveChangesClosure = onSaveChanges
    }
    
    func value<Value>(forKey key: String) async throws -> Value {
        // Wait for 0.1 second
        try await Task.sleep(nanoseconds: 1_000_000)
        
        guard store[key] != nil else {
            throw AsyncMutableFeatureFlagStoreMockError.valueNotFoundInStore
        }
        
        guard let value = store[key] as? Value else {
            throw AsyncMutableFeatureFlagStoreMockError.valueTypeMismatch
        }
        
        return value
    }
    
    func setValue<Value>(_ value: Value, forKey key: String) async throws {
        // Wait for 0.1 second
        try await Task.sleep(nanoseconds: 1_000_000)
        
        if let existingValue = store[key], type(of: existingValue) != type(of: value) {
            throw AsyncMutableFeatureFlagStoreMockError.valueTypeMismatch
        }
        
        store[key] = value
    }
    
    func removeValue(forKey key: String) async throws {
        // Wait for 0.1 second
        try await Task.sleep(nanoseconds: 1_000_000)
        
        guard store[key] != nil else {
            throw AsyncMutableFeatureFlagStoreMockError.valueNotFoundInStore
        }
        
        store[key] = nil
    }
    
    func saveChanges() async throws {
        onSaveChangesClosure()
    }
    
}

// MARK: - Error

fileprivate enum AsyncMutableFeatureFlagStoreMockError: Error {
    case valueNotFoundInStore
    case valueTypeMismatch
}

#endif
