//
//  MutableFeatureFlagStoreProtocol.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/26/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

public protocol MutableFeatureFlagStoreProtocol: AnyObject, FeatureFlagStoreProtocol {
    
    func setValue(_ value: Any, forKey key: String)
    
    func removeValue(forKey key: String)
    
}
