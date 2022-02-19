//
//  MutableFeatureFlagStoreMock.swift
//  YMFF
//
//  Created by Yakov Manshin on 5/30/21.
//  Copyright © 2021 Yakov Manshin. See the LICENSE file for license info.
//

import YMFF
#if !COCOAPODS
import YMFFProtocols
#endif

final class MutableFeatureFlagStoreMock: MutableFeatureFlagStoreProtocol {
    
    private var store: TransparentFeatureFlagStore
    private var onSaveChangesClosure: () -> Void
    
    init(store: TransparentFeatureFlagStore, onSaveChanges: @escaping () -> Void = { }) {
        self.store = store
        self.onSaveChangesClosure = onSaveChanges
    }
    
    func containsValue(forKey key: String) -> Bool {
        store[key] != nil
    }
    
    func value<Value>(forKey key: String) -> Value? {
        let expectedValueType = Value.self
        
        switch expectedValueType {
        case is Bool.Type,
             is Int.Type,
             is String.Type,
             is Optional<Bool>.Type,
             is Optional<Int>.Type,
             is Optional<String>.Type:
            return store[key] as? Value
        default:
            assertionFailure("The expected feature flag value type (\(expectedValueType)) is not supported")
            return nil
        }
    }
    
    func setValue<Value>(_ value: Value, forKey key: String) {
        store[key] = value
    }
    
    func removeValue(forKey key: String) {
        store.removeValue(forKey: key)
    }
    
    func saveChanges() {
        onSaveChangesClosure()
    }
    
}

