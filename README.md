# YMFF
## Feature management made easy

Every company I worked at needed a way to manage feature availability in shipped apps, without changing code. Surprisingly enough, [feature flags](https://en.wikipedia.org/wiki/Feature_toggle) (a.k.a. feature toggles a.k.a. feature switches) tend to cause a lot of struggle.

YMFF is a nice little library that makes management of features with feature flags—and management of the feature flags themselves—a bliss. YMFF provides a complete implementation of the mechanism: you get everything you need to start in just a few minutes. But since YMFF is protocol-based, you can replace nearly any component of the system with your own, customized implementation.

## Installation
To add YMFF to your project, use Xcode’s built-in support for Swift packages. Click File → Swift Packages → Add Package Dependency, and paste the following URL into the search field:

```
https://github.com/yakovmanshin/YMFF
```

You’re then prompted to select the version to install and indicate the desired update policy. I recommend starting with the latest version (it’s selected automatically), and choosing “up to next major” as the preferred update rule. Once you click Next, the package is fetched. Then select the target you’re going to use YMFF in. Click Finish, and you’re ready to go.

## Setup
All you need to start managing features with YMFF is at least one feature flag *store*—an object which conforms to `FeatureFlagStoreProtocol` and provides values that correspond to feature flag keys. `FeatureFlagStoreProtocol` has a single required method, `value(forKey:)`.
