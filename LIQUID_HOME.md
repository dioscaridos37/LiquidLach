# LiquidLach

LiquidLach — лёгкий лаунчер Android TV на базе [FLauncher](https://gitlab.com/flauncher/flauncher), переработанный для интерфейса 16:9.

## What changed

- Пультовая навигация Liquid Glass с крупными зонами фокуса.
- Spring-like focus scale, rounded glass cards and soft neon background glows.
- Direct APK install button in the top bar. The system package installer is used, so Android's normal confirmation and security checks remain active.
- Installed TV and sideloaded applications are discovered through Android `LauncherApps`, launched through their native Leanback/launcher intent, and refreshed when packages change.
- The existing FLauncher categories, ordering, wallpaper picker, settings, app info and uninstall actions are retained.
- В манифесте сохранены `HOME`, `LEANBACK_LAUNCHER` и `LAUNCHER_APP`, поэтому LiquidLach можно выбрать лаунчером по умолчанию на совместимой прошивке телевизора.

## Build

Install Flutter 3.7.5 or newer, Android SDK and platform tools, then run from this directory:

```shell
flutter pub get
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Install on the TV

```shell
adb connect 192.168.0.20:5555
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Телевизор может использовать другой порт ADB или потребовать включить **Настройки разработчика → Отладка по USB / Отладка по сети**. После установки нажмите Home и выберите **LiquidLach** лаунчером по умолчанию. Если прошивка не показывает выбор лаунчера, используйте настройки приложений по умолчанию или совместимый переназначатель кнопок.

## Wallpaper

Лаунчер сохраняет выбор обоев из FLauncher. Для встроенных обоев добавьте легально используемое изображение 16:9 в `assets/liquid_wallpaper.png` и укажите его в `pubspec.yaml`; иначе используется встроенный тёмный сине-фиолетовый градиент.

## License

The base project remains GPLv3. See `LICENSE`.
