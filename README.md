# YMFF: Feature management made easy

YMFF is a nice little library that makes managing features with feature flags—and managing feature flags themselves—a bliss, thanks to Swift’s [property wrappers](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Property-Wrappers) and (in the future) [macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros).

<details>
<summary>Why & How</summary>

Every company I worked for needed a way to manage availability of features in the apps already shipped to the users. Surprisingly, [*feature flags*](https://en.wikipedia.org/wiki/Feature_toggle) (a.k.a. *feature toggles* a.k.a. *feature switches*) tend to cause a lot of struggle.

**I aspire to change that.**

YMFF ships completely ready-to-use, right out of the box: you get everything you need to get started in just a few lines of code.

</details>

## Installation

I’m sure you know how to install dependencies. YMFF supports both SPM and CocoaPods.

<details>
<summary>Need Help?</summary>

### Swift Package Manager (SPM)
To add YMFF to your project, use Xcode’s built-in support for Swift packages. Click File → Add Package Dependencies, and paste the following URL into the search field:

```
https://github.com/yakovmanshin/YMFF
```

You’re then prompted to select the version to install and indicate the desired update policy. I recommend starting with the latest version (it’s selected automatically), and choosing “up to next major” as the update rule. Then select the target you want to link YMFF to. Click Finish—and you’re ready to go!

If you need to use YMFF in another Swift package, add it to the `Package.swift` file as a dependency:

```swift
.package(url: "https://github.com/yakovmanshin/YMFF", from: "4.0.0")
```

### CocoaPods
YMFF supports installation via [CocoaPods](https://youtu.be/iEAjvNRdZa0), but please keep in mind this support is provided on the best-effort basis.

Add the following to your Podfile:

```ruby
pod 'YMFF', '~> 4.0'
```

</details>

## Setup
YMFF relies on the concept of *feature-flag stores*—“sources of truth” for feature-flag values.

### Firebase Remote Config
Firebase Remote Config is one of the most popular tools to control feature flags remotely. YMFF integrates with Remote Config seamlessly, although with some manual action.

<details>
<summary>Typical Setup</summary>

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

Now, `RemoteConfig` is a valid *feature-flag store*.

Alternatively, you can create a custom wrapper object. That’s what I tend to do in my projects to achieve greater flexibility and avoid tight coupling.

</details>

## Usage
Here’s how you declare feature flags with YMFF:

```swift
import YMFF

// For convenience, organize feature flags in a separate namespace using an enum.
enum FeatureFlags {
    
    // `resolver` references one or more feature flag stores.
    private static var resolver = FeatureFlagResolver(configuration: .init(stores: [
        // If you want to change feature flag values from within your app, you’ll need at least one mutable store.
        // `RuntimeOverridesStore` is a YMFF-supplied object. It stores modified values until the app restarts.
        .mutable(RuntimeOverridesStore()),
        // `MyFeatureFlagStore.shared` is your object, conforming to `FeatureFlagStoreProtocol`.
        .immutable(MyFeatureFlagStore.shared),
    ]))
    
    // Feature flags are initialized with three pieces of data:
    // a key string, the default (fallback) value, and the resolver.
    @FeatureFlag("promo_enabled", default: false, resolver: resolver)
    static var promoEnabled
    
    // Feature flags aren’t limited to booleans. You can use any type of value!
    @FeatureFlag("number_of_banners", default: 3, resolver: resolver)
    static var numberOfBanners
    
    // Advanced: Sometimes you want to map raw values from the store
    // to native values used in your app. `MyFeatureFlagStore` below
    // stores values as strings, while the app uses an enum.
    // To switch between them, you use a `FeatureFlagValueTransformer`.
    @FeatureFlag(
        "promo_unit_kind",
        FeatureFlagValueTransformer { string in
            PromoUnitKind(rawValue: string)
        } rawValueFromValue: { kind in
            kind.rawValue
        },
        default: .image,
        resolver: resolver
    )
    static var promoUnitKind
    
}

// You can use custom types for feature-flag values.
enum PromoUnitKind: String {
    case text
    case image
    case video
}
```

To the code that makes use of a feature flag, the flag acts just like the type of its value:

```swift
if FeatureFlags.promoEnabled {
    switch FeatureFlags.promoUnitKind {
    case .text:
        displayPromoText()
    case .image:
        displayPromoBanners(count: FeatureFlags.numberOfBanners)
    case .video:
        playPromoVideo()
    }
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

You can use `UserDefaults` to read and write feature flag values. Your changes will persist when the app is restarted.

```swift
import YMFF

private static var resolver = FeatureFlagResolver(configuration: .init(stores: [.mutable(UserDefaultsStore())]))
```

That’s it!

### More

Feel free to browse the source files to learn more about the available options!

## [v4 Roadmap](https://github.com/yakovmanshin/YMFF/milestone/10)
* ✅ ~~[[#96](https://github.com/yakovmanshin/YMFF/issues/96)] Support for asynchronous feature-flag stores~~
* ✅ ~~[[#130](https://github.com/yakovmanshin/YMFF/issues/130)] Support for optional values~~ (see [#150](https://github.com/yakovmanshin/YMFF/issues/150))
* ✅ ~~[[#132](https://github.com/yakovmanshin/YMFF/issues/132)] Support for error throwing in feature-flag stores~~
* ✅ ~~[[#104](https://github.com/yakovmanshin/YMFF/issues/104)] Minimum compiler version: Swift 5.5 (Xcode 13)~~
* ✅ ~~[[#106](https://github.com/yakovmanshin/YMFF/issues/106)] Minimum deployment target: iOS 13, macOS 10.15~~

YMFF v4 is expected to be released in May 2024.

## [Next-Version Roadmap](https://github.com/yakovmanshin/YMFF/milestone/11)
* [[#124](https://github.com/yakovmanshin/YMFF/issues/124)] Swift macros for easier setup
* [[#113](https://github.com/yakovmanshin/YMFF/issues/113)] Thread-safety improvements
* [[#150](https://github.com/yakovmanshin/YMFF/issues/150)] Support for optional values in `UserDefaultsStore`
* [[#144](https://github.com/yakovmanshin/YMFF/issues/144)] Minimum compiler version: Swift 5.9 (Xcode 15)

This version is expected in late 2024, after Swift 6 is released.

## License and Copyright
YMFF is licensed under the Apache License. See the [LICENSE file](https://github.com/yakovmanshin/YMFF/blob/main/LICENSE) for details.

© 2020–2024 Yakov Manshin
