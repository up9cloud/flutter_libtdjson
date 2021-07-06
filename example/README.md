# libtdjson_example

Demonstrates how to use the libtdjson plugin.

## Getting Started

- Go to Telegram [my apps](https://my.telegram.org/apps) to create your own app
- Create `./assets/cfg/app.json` file, and put your credential in:

    ```json
    {
        "telegram_app_id": 123456,
        "telegram_app_hash": "xxxxxx"
    }
    ```

- Follow the plugin [installation](https://github.com/up9cloud/flutter_libtdjson)
- `flutter run`

## Dev memo

> Regenerate ./android

```bash
flutter create -a java --template plugin --platforms android --project-name libtdjson --org io.github.up9cloud.libtdjson _tmp
rm -fr android
rsync -av ./_tmp/example/android/ android/
rm -fr _tmp
```
