# YMFF: Feature management made easy

Every company I worked at needed a way to manage availability of features in the apps already shipped to customers. Surprisingly enough, [feature flags](https://en.wikipedia.org/wiki/Feature_toggle) (a.k.a. feature toggles a.k.a. feature switches) tend to cause a lot of struggle.

I aspire to change that.

YMFF is a nice little library that makes management of features with feature flags—and management of the feature flags themselves—a bliss, thanks to Swift’s [property wrappers](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617).

YMFF ships completely ready for use, right out of the box: you get everything you need to start in just a few minutes. But you can also replace nearly any component of the system with your own, customized implementation. Since version 2.0, the implementation and the protocols are in two separate targets (YMFF and YMFFProtocols, respectively).

## Installation

### Swift Package Manager (SPM)
To add YMFF to your project, use Xcode’s built-in support for Swift packages. Click File → Swift Packages → Add Package Dependency, and paste the following URL into the search field:

```
https://github.com/yakovmanshin/YMFF
```

You’re then prompted to select the version to install and indicate the desired update policy. I recommend starting with the latest version (it’s selected automatically), and choosing “up to next major” as the preferred update rule. Once you click Next, the package is fetched. Then select the target you’re going to use YMFF in. Click Finish, and you’re ready to go.

If you need to use YMFF in another Swift package, add it as a dependency:

```swift
.package(url: "https://github.com/yakovmanshin/YMFF", .upToNextMajor(from: "2.0.0"))
```

### CocoaPods
YMFF now supports installation via [CocoaPods](https://youtu.be/iEAjvNRdZa0).

Add the following to your Podfile:

```ruby
pod 'YMFF', '~> 2.1'
```

## Setup
All you need to start managing features with YMFF is at least one feature flag *store*—an object which conforms to `FeatureFlagStoreProtocol` and provides values that correspond to feature flag keys.

`FeatureFlagStoreProtocol` has two required methods: `containsValue(forKey:)` and `value(forKey:)`.

### Firebase Remote Config
Firebase’s Remote Config is one of the most popular tools to manage feature flags on the back-end side. Remote Config’s `RemoteConfigValue` requires use of different methods to retrieve values of different types. Integration of YMFF with Remote Config, although doesn’t look very pretty, is quite simple.

```swift
import FirebaseRemoteConfig
import YMFFProtocols

extension RemoteConfig: FeatureFlagStoreProtocol {
    
    public func containsValue(forKey key: String) -> Bool {
        self.allKeys(from: .remote).contains(key)
    }
    
    public func value<Value>(forKey key: String) -> Value? {
        // Remote Config returns a default value if the requested key doesn’t exist,
        // so you need to check the key for existence explicitly.
        guard containsValue(forKey: key) else { return nil }
        
        let remoteConfigValue = self[key]
        
        // You need to use different `RemoteConfigValue` methods, depending on the return type.
        // I know, it doesn’t look fancy.
        switch Value.self {
        case is Bool.Type:
            return remoteConfigValue.boolValue as? Value
        case is Data.Type:
            return remoteConfigValue.dataValue as? Value
        case is Double.Type:
            return remoteConfigValue.numberValue.doubleValue as? Value
        case is Int.Type:
            return remoteConfigValue.numberValue.intValue as? Value
        case is String.Type:
            return remoteConfigValue.stringValue as? Value
        default:
            return nil
        }
    }
    
}
```

Now `RemoteConfig` is a valid feature flag store.

Alternatively, instead of extending `RemoteConfig`, you can create a custom wrapper object. That’s what I prefer to do in my projects.

## Usage
Here’s the most basic way to use YMFF.

```swift
import YMFF

// For convenience, use an enum to create a namespace.
enum FeatureFlags {
    
    // `resolver` references one or more feature flag stores.
    // `MyFeatureFlagStore.shared` conforms to `FeatureFlagStoreProtocol`.
    private static var resolver = FeatureFlagResolver(configuration: .init(stores: [
        // If you want to change feature flag values from within your app, you’ll need at least one mutable store.
        .mutable(RuntimeOverridesStore()),
        .immutable(MyFeatureFlagStore.shared),
    ]))
    
    // Feature flags are initialized with three pieces of data:
    // a key string, the default value (used as fallback
    // when all feature flag stores fail to provide one), and the resolver.
    @FeatureFlag("promo_enabled", default: false, resolver: resolver)
    static var promoEnabled
    
    // Feature flags aren't limited to booleans. You can use any type of value.
    @FeatureFlag("number_of_banners", default: 3, resolver: resolver)
    static var numberOfBanners
    
}
```

To the code that makes use of a feature flag, the flag acts just like the type of its value:

```swift
if FeatureFlags.promoEnabled {
    displayPromoBanners(count: FeatureFlags.numberOfBanners)
}
```

### Overriding Values

YMFF lets you override feature flag values in mutable stores from within your app. When you do, the new value is set to the first mutable store found in resolver configuration.

Overriding a feature flag value is as simple as assigning a new value to the flag.

```swift
FeatureFlags.promoEnabled = true
```

If you can set a value, you should also be able to remove it. And you can, indeed. Calling `removeValueFromMutableStore()` on `FeatureFlag`’s *projected value* (i.e. the `FeatureFlag` instance itself, as opposed to its *wrapped value*) removes the value from the first mutable feature flag store which contains one.

```swift
// Here `FeatureFlags.$promoEnabled` has the type `FeatureFlag<Bool>`, 
// while `FeatureFlags.promoEnabled` is of type `Bool`.
FeatureFlags.$promoEnabled.removeValueFromMutableStore()
```

### `UserDefaults`

Since v1.2.0, you can use `UserDefaults` to read and write feature flag values. Your changes will persist when the app is restarted.

```swift
import YMFF

private static var resolver = FeatureFlagResolver(configuration: .init(stores: [.mutable(UserDefaultsStore())]))
```

That’s it!

### More

You can browse the source files to learn more about the options available to you. An autogenerated documentation is available at [opensource.ym.dev](https://opensource.ym.dev/YMFF/).

## Contributing
Contributions are welcome!

Have a look at [issues](https://github.com/yakovmanshin/YMFF/issues) to see the project’s current needs. Don’t hesitate to create new issues, especially if you intend to work on them yourself.

If you’d like to discuss something else regarding YMFF (or not), contact [me](https://github.com/yakovmanshin) via email (the address is in the profile).

## License and Copyright
YMFF is available under the terms of the Apache License, version 2.0. See the [LICENSE file](https://github.com/yakovmanshin/YMFF/blob/main/LICENSE) for details.

© 2020–2021 Yakov Manshin
