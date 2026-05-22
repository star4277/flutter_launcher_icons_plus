# flutter_launcher_icons_ohos

English docs are intentionally brief.  
For complete usage and OHOS details, read the Chinese guide:

- [README.zh-CN.md](./README.zh-CN.md)

## Quick Start

1. Add dependency:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.15.0
```

2. Add config (`pubspec.yaml`):

```yaml
flutter_launcher_icons:
  ohos:
    generate: true

    # Single icon mode:
    # image_path: "assets/icons/icon_any_name.jpg"

    # Layered icon mode:
    image_path: "assets/icons/start_any_name.jpg"
    image_path_foreground: "assets/icons/foreground_any_name.jpg"
    image_path_background: "assets/icons/background_any_name.jpg"
```

3. Run:

```bash
dart run flutter_launcher_icons
```

## Output Naming Rules (OHOS)

- Single mode output is always `icon.png`.
- Layered mode outputs are always:
  - `foreground.png`
  - `background.png`
  - `startIcon.png` (from `image_path`)

Input filenames can be arbitrary. The tool decodes common image formats and writes standard PNG outputs.

## Thanks

This project is based on the original `flutter_launcher_icons` work by Flutter Community and contributors, especially the original maintainer Mark O'Sullivan.
