//
//  SynchronousMutableFeatureFlagStoreProtocol.swift
//  YMFFProtocols
//
//  Created by Yakov Manshin on 9/29/22.
//  Copyright © 2022 Yakov Manshin. See the LICENSE file for license info.
//

public protocol SynchronousMutableFeatureFlagStoreProtocol: SynchronousFeatureFlagStoreProtocol, MutableFeatureFlagStoreProtocol {
    
    func setValueSync<Value>(_ value: Value, forKey key: String)
    
    func removeValueSync(forKey key: String)
    
    func saveChangesSync()
    
}

extension SynchronousMutableFeatureFlagStoreProtocol {
    
    public func setValue<Value>(_ value: Value, forKey key: String) async {
        setValueSync(value, forKey: key)
    }
    
    public func removeValue(forKey key: String) async {
        removeValueSync(forKey: key)
    }
    
    public func saveChanges() async {
        saveChangesSync()
    }
    
}

extension SynchronousMutableFeatureFlagStoreProtocol {
    
    public func saveChangesSync() { }
    
}
