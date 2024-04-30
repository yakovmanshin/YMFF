//
//  FeatureFlagResolverTests.swift
//  YMFF
//
//  Created by Yakov Manshin on 9/24/20.
//  Copyright © 2020 Yakov Manshin. See the LICENSE file for license info.
//

@testable import YMFF

import XCTest
#if !COCOAPODS
import YMFFProtocols
#endif

// MARK: - Configuration

final class FeatureFlagResolverTests: XCTestCase {
    
    private var resolver: FeatureFlagResolver!
    
    private var configuration: FeatureFlagResolverConfigurationProtocol!
    
    override func setUp() {
        super.setUp()
        
        configuration = FeatureFlagResolverConfiguration(stores: [])
        resolver = FeatureFlagResolver(configuration: configuration)
    }
    
    func test_configuration() {
        XCTAssertIdentical(resolver.configuration, configuration)
    }
    
    func test_value_noStores() async {
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_noStores() {
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_noSyncStores() {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noSyncStoreAvailable {
            XCTAssertEqual(store.containsValue_invocationCount, 0)
            XCTAssertEqual(store.value_invocationCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_notFoundInStores() async {
        let store1 = FeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2)]
        store1.containsValue_returnValue = false
        store2.containsValue_returnValue = false
        
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores {
            XCTAssertEqual(store1.containsValue_invocationCount, 1)
            XCTAssertEqual(store1.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store1.value_invocationCount, 0)
            XCTAssertEqual(store2.containsValue_invocationCount, 1)
            XCTAssertEqual(store2.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_notFoundInSyncStores() {
        let store1 = SynchronousFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2)]
        store1.containsValueSync_returnValue = false
        store2.containsValueSync_returnValue = false
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.valueNotFoundInPersistentStores {
            XCTAssertEqual(store1.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store1.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store2.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store1.valueSync_invocationCount, 0)
            XCTAssertEqual(store2.valueSync_invocationCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_foundInSingleStore() async {
        let store1 = FeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2)]
        store1.containsValue_returnValue = false
        store2.containsValue_returnValue = true
        store2.value_returnValue = "TEST_value2"
        
        do {
            let value: String = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store1.containsValue_invocationCount, 1)
            XCTAssertEqual(store1.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store1.value_invocationCount, 0)
            XCTAssertEqual(store2.containsValue_invocationCount, 1)
            XCTAssertEqual(store2.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 1)
            XCTAssertEqual(store2.value_keys, ["TEST_key1"])
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_foundInSingleSyncStore() {
        let store1 = SynchronousFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2)]
        store1.containsValueSync_returnValue = false
        store2.containsValueSync_returnValue = true
        store2.valueSync_returnValue = "TEST_value2"
        
        do {
            let value: String = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store1.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store1.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store1.valueSync_invocationCount, 0)
            XCTAssertEqual(store2.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store2.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_foundInMultipleStores() async {
        let store1 = FeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        let store3 = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2), .immutable(store3)]
        store1.containsValue_returnValue = false
        store2.containsValue_returnValue = true
        store2.value_returnValue = "TEST_value2"
        store3.containsValue_returnValue = true
        store3.value_returnValue = "TEST_value3"
        
        do {
            let value: String = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store1.containsValue_invocationCount, 1)
            XCTAssertEqual(store1.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.containsValue_invocationCount, 1)
            XCTAssertEqual(store2.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 1)
            XCTAssertEqual(store2.value_keys, ["TEST_key1"])
            XCTAssertEqual(store3.containsValue_invocationCount, 0)
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_foundInMultipleSyncStores() {
        let store1 = SynchronousFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store1), .immutable(store2), .immutable(store3)]
        store1.containsValueSync_returnValue = false
        store2.containsValueSync_returnValue = true
        store2.valueSync_returnValue = "TEST_value2"
        store3.containsValueSync_returnValue = true
        store3.valueSync_returnValue = "TEST_value3"
        
        do {
            let value: String = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store1.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store1.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store2.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.containsValueSync_invocationCount, 0)
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_typeMismatch() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        store.containsValue_returnValue = true
        store.value_returnValue = 123
        
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.typeMismatch {
            XCTAssertEqual(store.containsValue_invocationCount, 1)
            XCTAssertEqual(store.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_typeMismatch() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        store.containsValueSync_returnValue = true
        store.valueSync_returnValue = 123
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.typeMismatch {
            XCTAssertEqual(store.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_optionalValue() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        store.containsValue_returnValue = true
        store.value_returnValue = 123 as Int?
        
        do {
            let _: Int? = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.optionalValuesNotAllowed {
            XCTAssertEqual(store.containsValue_invocationCount, 1)
            XCTAssertEqual(store.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_optionalValue() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        store.containsValueSync_returnValue = true
        store.valueSync_returnValue = 123 as Int?
        
        do {
            let _: Int? = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.optionalValuesNotAllowed {
            XCTAssertEqual(store.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_noStores() async {
        do {
            try await resolver.setValue(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noStores() {
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noSyncStores() {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noSyncStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_noMutableStores() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            try await resolver.setValue(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noMutableStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noSyncMutableStores() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noSyncMutableStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_noValue() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        store.containsValue_returnValue = false
        
        do {
            try await resolver.setValue("TEST_value1", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.containsValue_invocationCount, 1)
            XCTAssertEqual(store.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as? String, "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_noValue() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        store.containsValueSync_returnValue = false
        
        do {
            try resolver.setValueSync("TEST_value1", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as? String, "TEST_value1")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        store.containsValue_returnValue = true
        store.value_returnValue = "TEST_value1"
        
        do {
            try await resolver.setValue("TEST_value2", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.containsValue_invocationCount, 1)
            XCTAssertEqual(store.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as? String, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        store.containsValueSync_returnValue = true
        store.valueSync_returnValue = "TEST_value1"
        
        do {
            try resolver.setValueSync("TEST_value2", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as? String, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_multipleMutableStores() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .immutable(store2), .mutable(store3)]
        store1.containsValue_returnValue = true
        store2.containsValue_returnValue = true
        store3.containsValueSync_returnValue = true
        store1.value_returnValue = "TEST_value1"
        store2.value_returnValue = "TEST_value2"
        store3.valueSync_returnValue = "TEST_value3"
        
        do {
            try await resolver.setValue("TEST_value4", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store1.containsValue_invocationCount, 1)
            XCTAssertEqual(store1.containsValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.containsValue_invocationCount, 0)
            XCTAssertTrue(store2.containsValue_keys.isEmpty)
            XCTAssertEqual(store3.containsValueSync_invocationCount, 0)
            XCTAssertTrue(store3.containsValueSync_keys.isEmpty)
            XCTAssertEqual(store1.setValue_invocationCount, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store1.setValue_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store3.setValueSync_invocationCount, 0)
            XCTAssertTrue(store3.setValueSync_keyValuePairs.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_multipleSyncMutableStores() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .immutable(store2), .mutable(store3)]
        store1.containsValueSync_returnValue = true
        store2.containsValueSync_returnValue = true
        store3.containsValueSync_returnValue = true
        store1.valueSync_returnValue = "TEST_value1"
        store2.valueSync_returnValue = "TEST_value2"
        store3.valueSync_returnValue = "TEST_value3"
        
        do {
            try resolver.setValueSync("TEST_value4", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store1.containsValueSync_invocationCount, 1)
            XCTAssertEqual(store1.containsValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.containsValueSync_invocationCount, 0)
            XCTAssertTrue(store2.containsValueSync_keys.isEmpty)
            XCTAssertEqual(store3.containsValueSync_invocationCount, 0)
            XCTAssertTrue(store3.containsValueSync_keys.isEmpty)
            XCTAssertEqual(store1.setValueSync_invocationCount, 1)
            XCTAssertEqual(store1.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store1.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store1.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store3.setValueSync_invocationCount, 0)
            XCTAssertTrue(store3.setValueSync_keyValuePairs.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_noStores() async {
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noStores() {
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noSyncStores() {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noSyncStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_noMutableStores() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noMutableStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noSyncMutableStores() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [.immutable(store)]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolverError.noSyncMutableStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_singleMutableStore() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            
            XCTAssertEqual(store.removeValue_invocationCount, 1)
            XCTAssertEqual(store.removeValue_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_singleSyncMutableStore() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store)]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            
            XCTAssertEqual(store.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store.removeValueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_multipleMutableStores() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .immutable(store2), .mutable(store3)]
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            
            XCTAssertEqual(store1.removeValue_invocationCount, 1)
            XCTAssertEqual(store1.removeValue_keys, ["TEST_key1"])
            XCTAssertEqual(store3.removeValueSync_invocationCount, 0)
            XCTAssertTrue(store3.removeValueSync_keys.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_multipleSyncMutableStores() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = MutableFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .mutable(store2), .mutable(store3)]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            
            XCTAssertEqual(store1.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store1.removeValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.removeValue_invocationCount, 0)
            XCTAssertTrue(store2.removeValue_keys.isEmpty)
            XCTAssertEqual(store3.removeValueSync_invocationCount, 0)
            XCTAssertTrue(store3.removeValueSync_keys.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_deinit() async throws {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [.mutable(store1), .mutable(store2)]
        
        configuration = nil
        resolver = nil
        
        try await Task.sleep(nanoseconds: 1_000_000)
        
        XCTAssertEqual(store1.saveChanges_invocationCount, 1)
        XCTAssertEqual(store2.saveChangesSync_invocationCount, 1)
    }
    
}
