# YMFF: Feature management made easy

Every company I worked at needed a way to manage feature availability in shipped apps, without changing code. Surprisingly enough, [feature flags](https://en.wikipedia.org/wiki/Feature_toggle) (a.k.a. feature toggles a.k.a. feature switches) tend to cause a lot of struggle.

YMFF is a nice little library that makes management of features with feature flags—and management of the feature flags themselves—a bliss, thanks to [property wrappers](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617). YMFF provides a complete implementation of the mechanism: you get everything you need to start in just a few minutes. But since YMFF is protocol-based, you can replace nearly any component of the system with your own, customized implementation.

## Installation
To add YMFF to your project, use Xcode’s built-in support for Swift packages. Click File → Swift Packages → Add Package Dependency, and paste the following URL into the search field:

```
https://github.com/yakovmanshin/YMFF
```

You’re then prompted to select the version to install and indicate the desired update policy. I recommend starting with the latest version (it’s selected automatically), and choosing “up to next major” as the preferred update rule. Once you click Next, the package is fetched. Then select the target you’re going to use YMFF in. Click Finish, and you’re ready to go.

## Setup
All you need to start managing features with YMFF is at least one feature flag *store*—an object which conforms to `FeatureFlagStoreProtocol` and provides values that correspond to feature flag keys. `FeatureFlagStoreProtocol` has a single required method, `value(forKey:)`.

### Firebase Remote Config
Firebase’s Remote Config is one of the most popular tools to manage feature flags on the back-end side. Remote Config’s `RemoteConfigValue` requires use of different methods to retrieve values of different types. Integration of YMFF with Remote Config, although doesn’t look very pretty, is quite simple.

```swift
import FirebaseRemoteConfig

extension RemoteConfig: FeatureFlagStoreProtocol {
    
    public func value<Value>(forKey key: String) -> Value? {
        // Remote Config returns a default value if the requested key doesn't exist,
        // so you need to check the key for existence explicitly.
        guard self.allKeys(from: .remote).contains(key) else { return nil }
        
        let remoteConfigValue = self[key]
        
        // You need to use different RemoteConfigValue methods, depending on the return type.
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

## Usage
Here’s the most basic way to use YMFF.

```swift
// For convenience, use an enum to create a namespace.
enum FeatureFlags {
    
    // `resolver` references one or more feature flag stores.
    // `MyFeatureFlagStore.shared` conforms to `FeatureFlagStoreProtocol`.
    private static var resolver: FeatureFlagResolverProtocol = {
        FeatureFlagResolver(configuration: .init(persistentStores: [
            .opaque(MyFeatureFlagStore.shared)
        ]))
    }
    
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

You can browse the source files to learn more about the options available to you. An extended documentation is coming later.

## Contributing
Contributions are welcome!

Have a look at [issues](https://github.com/yakovmanshin/YMFF/issues) to see the project’s current needs. Don’t hesitate to create new issues, especially if you intend to work on them yourself.

If you’d like to discuss something else regarding YMFF (or not), contact [me](https://github.com/yakovmanshin) via email (the address is in the profile).
