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

extension RemoteConfig: SynchronousFeatureFlagStore {
    
    public func valueSync<Value>(for key: FeatureFlagKey) -> Result<Value, FeatureFlagStoreError> {
        // Remote Config returns a default value if the requested key doesn’t exist,
        // so you need to check the key for existence explicitly.
        guard allKeys(from: .remote).contains(key) else {
            return .failure(.valueNotFound)
        }
        
        let remoteConfigValue = self[key]
        
        let value: Value?
        // You need to use different `RemoteConfigValue` methods, depending on the return type.
        // I know, it doesn’t look fancy.
        switch Value.self {
        case is Bool.Type:
            value = remoteConfigValue.boolValue as? Value
        case is Data.Type:
            value = remoteConfigValue.dataValue as? Value
        case is Double.Type:
            value = remoteConfigValue.numberValue.doubleValue as? Value
        case is Int.Type:
            value = remoteConfigValue.numberValue.intValue as? Value
        case is String.Type:
            value = remoteConfigValue.stringValue as? Value
        default:
            value = nil
        }
        
        if let value {
            return .success(value)
        } else {
            return .failure(.typeMismatch)
        }
    }
    
}
```

`RemoteConfig` is now a valid *feature-flag store*.

Alternatively, you can create a custom wrapper object. That’s what I do in my projects to avoid tight coupling.

</details>

## Usage
Here’s how you declare feature flags with YMFF:

```swift
import YMFF

// For convenience, organize feature flags in a separate namespace using an enum.
enum FeatureFlags {
    
    // `resolver` references one or more feature-flag stores.
    private static let resolver = FeatureFlagResolver(stores: [MyFeatureFlagStore.shared])
    
    // Feature flags are initialized with three pieces of data:
    // a key string, the default (fallback) value, and the resolver.
    @FeatureFlag("ads_enabled", default: false, resolver: Self.resolver)
    static var adsEnabled
    
    // Feature flags aren’t limited to booleans. You can use any type of value!
    @FeatureFlag("number_of_banners", default: 3, resolver: Self.resolver)
    static var numberOfBanners
    
    // Advanced: Sometimes you want to map raw values from the store
    // to native values used in your app. `MyFeatureFlagStore` below
    // stores values as strings, while the app uses an enum.
    // To switch between them, you use a `FeatureFlagValueTransformer`.
    @FeatureFlag(
        "ad_unit_kind",
        transformer: FeatureFlagValueTransformer { rawValue in
            AdUnitKind(rawValue: rawValue)
        } rawValueFromValue: { value in
            value.rawValue
        },
        default: .image,
        resolver: Self.resolver
    )
    static var adUnitKind
    
}

// You can use custom types for feature-flag values.
enum AdUnitKind: String {
    case text
    case image
    case video
}
```

To the code that makes use of a feature flag, the flag acts just like the type of its value:

```swift
if FeatureFlags.adsEnabled {
    switch FeatureFlags.adUnitKind {
    case .text:
        displayAdText()
    case .image:
        displayAdBanners(count: FeatureFlags.numberOfBanners)
    case .video:
        playAdVideo()
    }
}
```

### Overriding Values

YMFF lets you write feature-flag values to mutable stores. It’s as simple as assigning a new value to the flag:

```swift
FeatureFlags.adsEnabled = true
```

To remove the value, you call `removeValueFromMutableStores()` on `FeatureFlag`’s *projected value* (i.e. the `FeatureFlag` instance itself, as opposed to its *wrapped value*):

```swift
// Here `FeatureFlags.$adsEnabled` has the type `FeatureFlag<Bool>`, 
// while `FeatureFlags.adsEnabled` is of type `Bool`.
FeatureFlags.$adsEnabled.removeValueFromMutableStore()
```

### `UserDefaults`

You can use `UserDefaults` to read and write feature-flag values. Your changes will persist when the app restarts.

```swift
import YMFF

private static let resolver = FeatureFlagResolver(stores: [UserDefaultsStore()])
```

That’s it!

### More

Feel free to browse the source files to learn more about the available options!

## [Next-Version Roadmap](https://github.com/yakovmanshin/YMFF/milestone/11)
* [[#124](https://github.com/yakovmanshin/YMFF/issues/124)] Swift macros for easier setup
* [[#113](https://github.com/yakovmanshin/YMFF/issues/113)] Thread-safety improvements
* [[#150](https://github.com/yakovmanshin/YMFF/issues/150)] Support for optional values in `UserDefaultsStore`
* [[#144](https://github.com/yakovmanshin/YMFF/issues/144)] Minimum compiler version: Swift 5.9 (Xcode 15)

This version is expected in late 2024, after Swift 6 is released.
