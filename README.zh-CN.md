# Flutter Launcher Icons（中文）

[English README](README.md)

一个用于 Flutter 的命令行工具，用来快速生成/替换多平台启动图标。

## 使用指南

### 1. 生成配置文件

```shell
dart run flutter_launcher_icons:generate
```

会在 Flutter 项目根目录生成 `flutter_launcher_icons.yaml`。

如果要指定文件名或路径：

```shell
dart run flutter_launcher_icons:generate -f <your config file name here>
```

如果要覆盖已存在的配置：

```shell
dart run flutter_launcher_icons:generate -o
```

也可以直接写在 `pubspec.yaml` 里，例如：

```yaml
dev_dependencies:
  flutter_launcher_icons: "^0.14.4"

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  ohos:
    generate: true
    image_path: "path/to/image.png"
    # 可选：分层图标模式
    image_path_foreground: "path/to/foreground.png"
    image_path_background: "path/to/background.png"
    background_color: "#hexcode"
  image_path: "assets/icon/icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "path/to/image.png"
    background_color: "#hexcode"
    theme_color: "#hexcode"
  windows:
    generate: true
    image_path: "path/to/image.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "path/to/image.png"
```

### 2. 执行生成

```shell
flutter pub get
dart run flutter_launcher_icons
```

如果你的配置文件不是默认的 `flutter_launcher_icons.yaml` 或 `pubspec.yaml`，需要加 `-f`：

```shell
flutter pub get
dart run flutter_launcher_icons -f <your config file name here>
```

## 配置项说明

### 全局

- `image_path`：通用图标路径（各平台未单独指定时会回退到这里）。

### Android

- `android`：`true/false` 或自定义图标名。
- `image_path_android`：Android 专用图标路径。
- `min_sdk_android`：Android min sdk。
- `adaptive_icon_background`：自适应图标背景色或背景图。
- `adaptive_icon_foreground`：自适应图标前景图。
- `adaptive_icon_foreground_inset`：前景内边距百分比，默认 `16`。
- `adaptive_icon_monochrome`：Android 13+ 单色主题图标。

### iOS

- `ios`：`true/false` 或自定义图标名。
- `image_path_ios`：iOS 专用图标路径。
- `remove_alpha_ios`：移除透明通道。
- `image_path_ios_dark_transparent`：iOS 18+ 深色模式图标。
- `image_path_ios_tinted_grayscale`：iOS 18+ 着色模式灰度图标。
- `desaturate_tinted_to_grayscale_ios`：自动去饱和为灰度图。
- `background_color_ios`：移除透明通道时使用的背景色。

### OHOS

- `ohos`：
  - `true`：启用 OHOS 图标生成。
  - `false`：跳过 OHOS。
  - 也支持嵌套写法：`ohos.generate`、`ohos.image_path`、`ohos.image_path_foreground`、`ohos.image_path_background`、`ohos.background_color`。
- `image_path_ohos`：OHOS 单图模式图标路径（未设置时回退到全局 `image_path`）。
- `image_path_ohos_foreground`：OHOS 分层前景图路径。
- `image_path_ohos_background`：OHOS 分层背景图路径。
- `background_color_ohos`：OHOS 单图模式下，用于处理透明通道的背景色（可选）。

OHOS 规则：
- 单图模式：生成 `icon.png`。
- 分层模式：同时提供前景和背景路径后启用，生成 `foreground.png`、`background.png`，并使用 `image_path`（或 `image_path_ohos`）生成 `startIcon.png`。
- 嵌套配置下也支持 `image_path_ohos_*` 与 `background_color_ohos` 这些等价字段。

### Web

- `web.generate`：是否生成。
- `web.image_path`：Web 图标路径。
- `web.background_color`：写入 `web/manifest.json`。
- `web.theme_color`：写入 `web/manifest.json`。

### Windows

- `windows.generate`：是否生成。
- `windows.image_path`：Windows 图标路径。
- `windows.icon_size`：图标大小，范围 `48-256`，默认 `48`。

### macOS

- `macos.generate`：是否生成。
- `macos.image_path`：macOS 图标路径。

## Flavor 支持

可以按 flavor 创建配置文件：`flutter_launcher_icons-<flavor>.yaml`。

例如：`flutter_launcher_icons-development.yaml`。

## 问题反馈

如果遇到问题，请在这里提交：

- https://github.com/fluttercommunity/flutter_launcher_icons/issues

