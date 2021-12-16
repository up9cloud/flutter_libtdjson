# flutter_libtdjson

[![pub package](https://img.shields.io/pub/v/libtdjson.svg)](https://pub.dev/packages/libtdjson) [![pub points](https://badges.bar/libtdjson/pub%20points)](https://pub.dev/packages/libtdjson/score) [![popularity](https://badges.bar/libtdjson/popularity)](https://pub.dev/packages/libtdjson/score) [![likes](https://badges.bar/libtdjson/likes)](https://pub.dev/packages/libtdjson/score)

A flutter plugin for [TDLib JSON interface](https://github.com/tdlib/td#using-from-other-programming-languages), ffi binding.

## Lib versions

| package | td                            |
| ------- | ----------------------------- |
| 0.1.3   | 1.7.9                         |
| 0.1.2   | 1.7.0 (Android), latest (iOS) |

## Supported architectures

Make sure you are using supported one

| Platform         | Architecture |     |
| ---------------- | ------------ | --- |
| Android          | armeabi-v7a  | ✅   |
|                  | arm64-v8a    | ✅   |
| Android emulator | x86          | ❌   |
|                  | x86_64       | ✅   |
| iOS              | armv7        | ❌   |
|                  | armv7s       | ❌   |
|                  | arm64        | ✅   |
| iOS simulator    | i386         | ❌   |
|                  | x86_64       | ✅   |
|                  | arm64 (M1)   | ❌   |
| macOS            | i386         | ❌   |
|                  | x86_64       | ✅   |
|                  | arm64 (M1)   | ✅   |

## Installation

- Update `pubspec.yaml`:

  ```yml
  dependencies:
    libtdjson: ^0.1.3
  ```

- If you want to build android, you have to add envs for github maven, see `./android/build.gradle`

  ```bash
  export GITHUB_ACTOR=<username>
  export GITHUB_TOKEN=<personal access token>
  ```

- If you want to set `tdlibParameters.database_directory` outside work dir, make sure you request the storage permission, e.q. `android/app/src/main/AndroidManifest.xml`

  ```xml
  <manifest>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  <manifest/>
  ```

- If you want to build macos, have to set network permission in `./macos/Runner/*.entitlements` files

  ```xml
  <dict>
      <key>com.apple.security.network.client</key>
      <true/>
  </dict>
  ```

## Dev memo

> Bump tdlib version

- Bump the td version of [android-libtdjson](https://github.com/up9cloud/android-libtdjson)
- Bump the td version of [ios-libtdjson](https://github.com/up9cloud/ios-libtdjson)
- Bump the android dependency version in `./android/app/build.gradle`
- Bump the ios dependency version in `./ios/libtdjson.podspec`
- Bump the macos dependency version in `./macos/libtdjson.podspec`
- Run `./example` for ios, android, macos
- Bump the package version in `./pubspec.yaml`
- Bump version info in `./README.md`
- Commit and push
