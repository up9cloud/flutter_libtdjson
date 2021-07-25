# libtdjson_example

Demonstrates how to use the libtdjson plugin.

## Getting Started

- Go to Telegram [my apps](https://my.telegram.org/apps) to create your own app
- Create `./assets/cfg/app.json` file, and put your credential in:

    ```json
    {
        "telegram_api_id": 123456,
        "telegram_api_hash": "xxxxxx"
    }
    ```

- Follow the plugin [installation](https://github.com/up9cloud/flutter_libtdjson)
- `flutter run`

## Dev memo

> Regenerate ./android

```bash
flutter create -a java --template plugin --platforms android --project-name libtdjson --org io.github.up9cloud.libtdjson _tmp
rm -fr android
mv ./_tmp/example/android .
rm -fr _tmp
```

> Regenerate ./ios

```bash
flutter create -i objc --template plugin --platforms ios --project-name libtdjson _tmp
rm -fr ios
mv ./_tmp/example/ios .
rm -fr _tmp
```

> Regenerate ./macos

```bash
flutter create --template plugin --platforms macos --project-name libtdjson _tmp
rm -fr macos
mv ./_tmp/example/macos .
rm -fr _tmp
```

Add this part to `./macos/Runner/DebugProfile.entitlements`, see [setup entitlements](https://flutter.dev/desktop#setting-up-entitlements)

```xml
<dict>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
```

> Error: Undefined symbols for ...

```bash
./ios_cleanup_run.sh
```

> [!] CocoaPods could not find compatible versions for pod "flutter_libtdjson": In snapshot (Podfile.lock)

```bash
pod repo update
./macos_cleanup_run.sh
```
