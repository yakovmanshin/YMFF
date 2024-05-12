//
//  FeatureFlagResolverTests.swift
//  YMFFTests
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
    
    private var configuration: FeatureFlagResolverConfiguration!
    
    override func setUp() {
        super.setUp()
        
        configuration = FeatureFlagResolver.Configuration(stores: [])
        resolver = FeatureFlagResolver(configuration: configuration)
    }
    
    func test_configuration() {
        XCTAssertIdentical(resolver.configuration, configuration)
    }
    
    func test_init_withConfiguration() {
        let store1 = FeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        let configuration = FeatureFlagResolver.Configuration(stores: [store1, store2])
        
        let resolver = FeatureFlagResolver(configuration: configuration)
        
        XCTAssertIdentical(resolver.configuration, configuration)
        XCTAssertIdentical(resolver.configuration.stores[0] as AnyObject, store1)
        XCTAssertIdentical(resolver.configuration.stores[1] as AnyObject, store2)
    }
    
    func test_init_withStores() {
        let store1 = FeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        
        let resolver = FeatureFlagResolver(stores: [store1, store2])
        
        XCTAssertIdentical(resolver.configuration.stores[0] as AnyObject, store1)
        XCTAssertIdentical(resolver.configuration.stores[1] as AnyObject, store2)
    }
    
    func test_value_noStores() async {
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_noStores() {
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_noSyncStores() {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable {
            XCTAssertEqual(store.value_invocationCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_notFoundInStores() async {
        let store1 = FeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        store1.value_result = .failure(.valueNotFound)
        store2.value_result = .failure(.valueNotFound)
        
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.valueNotFoundInStores {
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 1)
            XCTAssertEqual(store2.value_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_notFoundInSyncStores() {
        let store1 = SynchronousFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        store1.valueSync_result = .failure(.valueNotFound)
        store2.valueSync_result = .failure(.valueNotFound)
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.valueNotFoundInStores {
            XCTAssertEqual(store1.valueSync_invocationCount, 1)
            XCTAssertEqual(store1.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_foundInSingleStore() async {
        let store1 = FeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        store1.value_result = .failure(.valueNotFound)
        store2.value_result = .success("TEST_value2")
        
        do {
            let value: String = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
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
        configuration.stores = [store1, store2]
        store1.valueSync_result = .failure(.valueNotFound)
        store2.valueSync_result = .success("TEST_value2")
        
        do {
            let value: String = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store1.valueSync_invocationCount, 1)
            XCTAssertEqual(store1.valueSync_keys, ["TEST_key1"])
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
        configuration.stores = [store1, store2, store3]
        store1.value_result = .failure(.valueNotFound)
        store2.value_result = .success("TEST_value2")
        store3.value_result = .success("TEST_value3")
        
        do {
            let value: String = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 1)
            XCTAssertEqual(store2.value_keys, ["TEST_key1"])
            XCTAssertEqual(store3.value_invocationCount, 0)
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_foundInMultipleSyncStores() {
        let store1 = SynchronousFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.valueSync_result = .failure(.valueNotFound)
        store2.valueSync_result = .success("TEST_value2")
        store3.valueSync_result = .success("TEST_value3")
        
        do {
            let value: String = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store1.valueSync_invocationCount, 1)
            XCTAssertEqual(store1.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 0)
            XCTAssertEqual(value, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_typeMismatch() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        store.value_result = .success(123)
        
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_typeMismatch() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        store.valueSync_result = .success(123)
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_optionalValue_nonNil() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.value_result = .success(optionalInt as Any)
        
        do {
            let value: Int? = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssert(type(of: value) == Optional<Int>.self)
            XCTAssertEqual(value, 123)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_optionalValue_nonNil() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.valueSync_result = .success(optionalInt as Any)
        
        do {
            let value: Int? = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssert(type(of: value) == Optional<Int>.self)
            XCTAssertEqual(value, 123)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_optionalValue_nil() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalString: String? = nil
        store.value_result = .success(optionalString as Any)
        
        do {
            let value: String? = try await resolver.value(for: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssert(type(of: value) == Optional<String>.self)
            XCTAssertNil(value)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_optionalValue_nil() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalString: String? = nil
        store.valueSync_result = .success(optionalString as Any)
        
        do {
            let value: String? = try resolver.valueSync(for: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssert(type(of: value) == Optional<String>.self)
            XCTAssertNil(value)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_value_otherStoreError() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        let storeError = NSError(domain: "TEST_Error_Domain", code: 123)
        store.value_result = .failure(.otherError(storeError))
        
        do {
            let _: String = try await resolver.value(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(let error) {
            XCTAssertIdentical(error as NSError, storeError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_valueSync_otherStoreError() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        let storeError = NSError(domain: "TEST_Error_Domain", code: 123)
        store.valueSync_result = .failure(.otherError(storeError))
        
        do {
            let _: String = try resolver.valueSync(for: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(let error) {
            XCTAssertIdentical(error as NSError, storeError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_noStores() async {
        do {
            try await resolver.setValue(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noStores() {
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noSyncStores() {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_noMutableStores() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try await resolver.setValue(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_noSyncMutableStores() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try resolver.setValueSync(123, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_noValue() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        store.value_result = .failure(.valueNotFound)
        
        do {
            try await resolver.setValue("TEST_value1", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
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
        configuration.stores = [store]
        store.valueSync_result = .failure(.valueNotFound)
        
        do {
            try resolver.setValueSync("TEST_value1", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
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
        configuration.stores = [store]
        store.value_result = .success("TEST_value1")
        
        do {
            try await resolver.setValue("TEST_value2", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
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
        configuration.stores = [store]
        store.valueSync_result = .success("TEST_value1")
        
        do {
            try resolver.setValueSync("TEST_value2", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as? String, "TEST_value2")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue_nonNilToNonNil() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.value_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = 456
            try await resolver.setValue(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as! Int?, 456)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue_nonNilToNonNil() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.valueSync_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = 456
            try resolver.setValueSync(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as! Int?, 456)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue_nilToNonNil() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.value_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = nil
            try await resolver.setValue(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as! Int?, nil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue_nilToNonNil() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = 123
        store.valueSync_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = nil
            try resolver.setValueSync(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as! Int?, nil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue_nonNilToNil() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = nil
        store.value_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = 456
            try await resolver.setValue(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as! Int?, 456)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue_nonNilToNil() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = nil
        store.valueSync_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = 456
            try resolver.setValueSync(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as! Int?, 456)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue_nilToNil() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = nil
        store.value_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = nil
            try await resolver.setValue(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 1)
            XCTAssertEqual(store.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValue_keyValuePairs[0].1 as! Int?, nil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue_nilToNil() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store]
        let optionalInt: Int? = nil
        store.valueSync_result = .success(optionalInt as Any)
        
        do {
            let newValue: Int? = nil
            try resolver.setValueSync(newValue, toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store.setValueSync_keyValuePairs[0].1 as! Int?, nil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_singleMutableStore_existingValue_typeMismatch() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        store.value_result = .success("TEST_value1")
        
        do {
            try await resolver.setValue(456, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store.value_invocationCount, 1)
            XCTAssertEqual(store.value_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValue_invocationCount, 0)
            XCTAssertTrue(store.setValue_keyValuePairs.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_singleSyncMutableStore_existingValue_typeMismatch() {
        let store = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store]
        store.valueSync_result = .success("TEST_value1")
        
        do {
            try resolver.setValueSync(456, toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store.valueSync_invocationCount, 1)
            XCTAssertEqual(store.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store.setValueSync_invocationCount, 0)
            XCTAssertTrue(store.setValueSync_keyValuePairs.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_multipleMutableStores() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = FeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.value_result = .failure(.valueNotFound)
        store2.value_result = .success("TEST_value2")
        store3.valueSync_result = .success("TEST_value3")
        
        do {
            try await resolver.setValue("TEST_value4", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
            XCTAssertEqual(store2.value_invocationCount, 1)
            XCTAssertEqual(store2.value_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 1)
            XCTAssertEqual(store3.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store1.setValue_invocationCount, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store1.setValue_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store3.setValueSync_invocationCount, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_multipleMutableStores() {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.value_result = .failure(.valueNotFound)
        store2.valueSync_result = .success("TEST_value2")
        store3.valueSync_result = .success("TEST_value3")
        
        do {
            try resolver.setValueSync("TEST_value4", toMutableStoreUsing: "TEST_key1")
            
            XCTAssertEqual(store1.value_invocationCount, 0)
            XCTAssertTrue(store1.value_keys.isEmpty)
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 1)
            XCTAssertEqual(store3.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store1.setValue_invocationCount, 0)
            XCTAssertTrue(store1.setValue_keyValuePairs.isEmpty)
            XCTAssertEqual(store3.setValueSync_invocationCount, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_partialStoreError() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        let store3 = MutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.value_result = .failure(.valueNotFound)
        store1.setValue_result = .failure(TestFeatureFlagStoreError.someError1)
        store2.valueSync_result = .success("TEST_value2")
        store2.setValueSync_result = .success(())
        store3.value_result = .success("TEST_value3")
        store3.setValue_result = .failure(TestFeatureFlagStoreError.someError2)
        
        do {
            try await resolver.setValue("TEST_value4", toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(TestFeatureFlagStoreError.someError2) {
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.value_invocationCount, 1)
            XCTAssertEqual(store3.value_keys, ["TEST_key1"])
            XCTAssertEqual(store1.setValue_invocationCount, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store1.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store1.setValue_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store2.setValueSync_invocationCount, 1)
            XCTAssertEqual(store2.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store2.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store2.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store3.setValue_invocationCount, 1)
            XCTAssertEqual(store3.setValue_keyValuePairs.count, 1)
            XCTAssertEqual(store3.setValue_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store3.setValue_keyValuePairs[0].1 as? String, "TEST_value4")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_partialStoreError() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.valueSync_result = .failure(.valueNotFound)
        store1.setValueSync_result = .failure(TestFeatureFlagStoreError.someError1)
        store2.valueSync_result = .success("TEST_value2")
        store2.setValueSync_result = .success(())
        store3.valueSync_result = .success("TEST_value3")
        store3.setValueSync_result = .failure(TestFeatureFlagStoreError.someError2)
        
        do {
            try resolver.setValueSync("TEST_value4", toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(TestFeatureFlagStoreError.someError2) {
            XCTAssertEqual(store1.valueSync_invocationCount, 1)
            XCTAssertEqual(store1.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 1)
            XCTAssertEqual(store3.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store1.setValueSync_invocationCount, 1)
            XCTAssertEqual(store1.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store1.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store1.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store2.setValueSync_invocationCount, 1)
            XCTAssertEqual(store2.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store2.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store2.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
            XCTAssertEqual(store3.setValueSync_invocationCount, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs.count, 1)
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].0, "TEST_key1")
            XCTAssertEqual(store3.setValueSync_keyValuePairs[0].1 as? String, "TEST_value4")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValue_multipleStores_typeMismatch() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.value_result = .failure(.valueNotFound)
        store2.valueSync_result = .success(123)
        store3.valueSync_result = .success("TEST_value3")
        
        do {
            try await resolver.setValue("TEST_value4", toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store1.value_invocationCount, 1)
            XCTAssertEqual(store1.value_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 0)
            XCTAssertTrue(store3.valueSync_keys.isEmpty)
            XCTAssertEqual(store1.setValue_invocationCount, 0)
            XCTAssertTrue(store1.setValue_keyValuePairs.isEmpty)
            XCTAssertEqual(store3.setValueSync_invocationCount, 0)
            XCTAssertTrue(store3.setValueSync_keyValuePairs.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_setValueSync_multipleStores_typeMismatch() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = SynchronousFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        store1.valueSync_result = .failure(.valueNotFound)
        store2.valueSync_result = .success(123)
        store3.valueSync_result = .success("TEST_value3")
        
        do {
            try resolver.setValueSync("TEST_value4", toMutableStoreUsing: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(FeatureFlagStoreError.typeMismatch) {
            XCTAssertEqual(store1.valueSync_invocationCount, 1)
            XCTAssertEqual(store1.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.valueSync_invocationCount, 1)
            XCTAssertEqual(store2.valueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store3.valueSync_invocationCount, 0)
            XCTAssertTrue(store3.valueSync_keys.isEmpty)
            XCTAssertEqual(store1.setValueSync_invocationCount, 0)
            XCTAssertTrue(store1.setValueSync_keyValuePairs.isEmpty)
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
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noStores() {
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noSyncStores() {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_noMutableStores() async {
        let store = FeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_noSyncMutableStores() {
        let store = SynchronousFeatureFlagStoreMock()
        configuration.stores = [store]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.noStoreAvailable { } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_singleMutableStore() async {
        let store = MutableFeatureFlagStoreMock()
        configuration.stores = [store]
        
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
        configuration.stores = [store]
        
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
        configuration.stores = [store1, store2, store3]
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            
            XCTAssertEqual(store1.removeValue_invocationCount, 1)
            XCTAssertEqual(store1.removeValue_keys, ["TEST_key1"])
            XCTAssertEqual(store3.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store3.removeValueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_multipleSyncMutableStores() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = MutableFeatureFlagStoreMock()
        let store3 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2, store3]
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            
            XCTAssertEqual(store1.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store1.removeValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.removeValue_invocationCount, 0)
            XCTAssertTrue(store2.removeValue_keys.isEmpty)
            XCTAssertEqual(store3.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store3.removeValueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStore_storeError() async {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        store1.removeValue_result = .failure(.someError1)
        store2.removeValueSync_result = .success(())
        
        do {
            try await resolver.removeValueFromMutableStore(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(let error) {
            XCTAssertEqual(error as? TestFeatureFlagStoreError, .someError1)
            XCTAssertEqual(store1.removeValue_invocationCount, 1)
            XCTAssertEqual(store1.removeValue_keys, ["TEST_key1"])
            XCTAssertEqual(store2.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store2.removeValueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_removeValueFromMutableStoreSync_storeError() {
        let store1 = SynchronousMutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        store1.removeValueSync_result = .failure(.someError1)
        store2.removeValueSync_result = .success(())
        
        do {
            try resolver.removeValueFromMutableStoreSync(using: "TEST_key1")
            XCTFail("Expected an error")
        } catch FeatureFlagResolver.Error.storeError(let error) {
            XCTAssertEqual(error as? TestFeatureFlagStoreError, .someError1)
            XCTAssertEqual(store1.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store1.removeValueSync_keys, ["TEST_key1"])
            XCTAssertEqual(store2.removeValueSync_invocationCount, 1)
            XCTAssertEqual(store2.removeValueSync_keys, ["TEST_key1"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_deinit() async throws {
        let store1 = MutableFeatureFlagStoreMock()
        let store2 = SynchronousMutableFeatureFlagStoreMock()
        configuration.stores = [store1, store2]
        
        configuration = nil
        resolver = nil
        
        try await Task.sleep(nanoseconds: 1_000_000)
        
        XCTAssertEqual(store1.saveChanges_invocationCount, 1)
        XCTAssertEqual(store2.saveChangesSync_invocationCount, 1)
    }
    
}
