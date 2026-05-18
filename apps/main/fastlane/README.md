fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android upload_firebase_dev

```sh
[bundle exec] fastlane android upload_firebase_dev
```

Deploy Android APK to Firebase App Distribution - Dev

### android upload_firebase_staging

```sh
[bundle exec] fastlane android upload_firebase_staging
```

Deploy Android APK to Firebase App Distribution - Staging

### android upload_firebase_sandbox

```sh
[bundle exec] fastlane android upload_firebase_sandbox
```

Deploy Android APK to Firebase App Distribution - Sandbox

### android upload_firebase_prod

```sh
[bundle exec] fastlane android upload_firebase_prod
```

Deploy Android APK to Firebase App Distribution - Production

### android deploy_play_store

```sh
[bundle exec] fastlane android deploy_play_store
```

Deploy to Google Play Store

----


## iOS

### ios upload_firebase_dev

```sh
[bundle exec] fastlane ios upload_firebase_dev
```

Deploy iOS IPA to Firebase App Distribution - Dev

### ios upload_firebase_staging

```sh
[bundle exec] fastlane ios upload_firebase_staging
```

Deploy iOS IPA to Firebase App Distribution - Staging

### ios upload_firebase_sandbox

```sh
[bundle exec] fastlane ios upload_firebase_sandbox
```

Deploy iOS IPA to Firebase App Distribution - Sandbox

### ios upload_firebase_prod

```sh
[bundle exec] fastlane ios upload_firebase_prod
```

Deploy iOS IPA to Firebase App Distribution - Production

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload to TestFlight

### ios deploy_app_store

```sh
[bundle exec] fastlane ios deploy_app_store
```

Deploy to App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
