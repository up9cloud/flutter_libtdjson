# flutter_libtdjson

![Build Status](https://github.com/up9cloud/flutter_libtdjson/actions/workflows/main.yml/badge.svg)
[![Pub Version](https://img.shields.io/pub/v/libtdjson)](https://pub.dev/packages/libtdjson)
[![Pub Likes](https://img.shields.io/pub/likes/libtdjson)](https://pub.dev/packages/libtdjson/score)
[![Pub Points](https://img.shields.io/pub/points/libtdjson)](https://pub.dev/packages/libtdjson/score)
[![popularity](https://img.shields.io/pub/popularity/libtdjson)](https://pub.dev/packages/libtdjson/score)

A flutter plugin for [TDLib JSON interface](https://github.com/tdlib/td#using-from-other-programming-languages), ffi binding.

## Lib versions

| package | td version (Android) | td version (iOS) | td version (macOS) |
| ------- | -------------------- | ---------------- | ------------------ |
| 0.3.0   | 1.8.65               | 1.8.65           | 1.8.65             |
| 0.2.2   | 1.8.47               | 1.8.47           | 1.8.47             |
| 0.2.1   | 1.8.31               | 1.8.31           | 1.8.31             |
| 0.2.0   | 1.8.30               | 1.8.30           | 1.8.30             |
| 0.1.4   | 1.8.1                | 1.8.1            | 1.8.1              |
| 0.1.3   | 1.7.9                | 1.7.9            | 1.7.9              |
| 0.1.2   | 1.7.0                | latest           | latest             |

## Supported architectures

Make sure you are using supported one

| Platform         | Architecture |     |
| ---------------- | ------------ | --- |
| Android          | armeabi-v7a  | ✅   |
|                  | arm64-v8a    | ✅   |
| Android emulator | x86          | ✅   |
|                  | x86_64       | ✅   |
| iOS              | armv7        | ❌   |
|                  | armv7s       | ❌   |
|                  | arm64        | ✅   |
| iOS simulator    | i386         | ❌   |
|                  | x86_64       | ✅   |
|                  | arm64 (M1)   | ✅   |
| macOS            | i386         | ❌   |
|                  | x86_64       | ✅   |
|                  | arm64 (M1)   | ✅   |

## Installation

- Update `pubspec.yaml`:

  ```yml
  dependencies:
    libtdjson: ^0.3.0
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

### Bump TDLib version

- Bump the td version of [android-libtdjson](https://github.com/up9cloud/android-libtdjson)
- Bump the dependency version in `./android/build.gradle`
- Run `./example` for android

  ```bash
  cd ./example
  flutter run -d emulator-5554
  ```

- Bump the td version of [ios-libtdjson](https://github.com/up9cloud/ios-libtdjson)
- Bump the dependency version in `./macos/libtdjson.podspec` (s.dependency)
- Run `./example` for macos

  ```bash
  cd ./example/macos
  rm -rf Pods Podfile.lock
  pod install --repo-update
  #pod repo remove trunk
  pod repo update
  pod update
  cd ..
  flutter run -d macos
  ```

- Bump the dependency version in `./ios/libtdjson.podspec`
- Run `./example` for ios simulator

  ```bash
  cd ./example/ios
  pod repo remove trunk
  pod update
  cd ..
  flutter run --debug
  ```

- Bump the package version in `./pubspec.yaml`
- Add changelog for new version in `./CHANGELOG.md`
- Bump version info in `./README.md`
- Git commit (message example: `bump td to vx.x.x`)
- Git add tag (`git tag v?.?.?`, the tag version should be same as the version in pubspec.yaml)
- Push with tags (`git push && git push --tags`)
- Wait for CI task

### Manually publish

- https://dart.dev/tools/pub/publishing

```bash
dart pub publish

# credentials file on macos
cat ~/Library/Application\ Support/dart/pub-credentials.json
```
