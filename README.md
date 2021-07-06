# flutter_libtdjson

A flutter plugin for [TDLib JSON interface](https://github.com/tdlib/td#using-from-other-programming-languages), ffi binding.

## Install

- Update `pubspec.yaml`:

```yml
dependencies:
  libtdjson: ^0.1.0
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
