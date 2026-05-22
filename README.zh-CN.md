# flutter_launcher_icons_ohos 使用说明

这是一个针对 OHOS 图标替换场景增强过的 `flutter_launcher_icons` 分支版本。

## 版本

- 当前版本：`0.15.0`

## 安装

在 Flutter 项目的 `pubspec.yaml` 中添加：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.15.0
```

## OHOS 配置

建议使用和 `web/windows` 一样的层级写法：

```yaml
flutter_launcher_icons:
  ohos:
    generate: true
```

支持两种模式：

### 1) 单图模式

```yaml
flutter_launcher_icons:
  ohos:
    generate: true
    image_path: "assets/icons/your_icon_name.jpg"
```

行为：

- 输出文件名固定为 `icon.png`（不取决于输入文件名）。
- 会清理 layered 相关文件（`foreground/background/layered_image/startIcon`）。
- `module.json5` 中 `icon/startWindowIcon` 会同步为单图引用。

### 2) 前景/背景分层模式

```yaml
flutter_launcher_icons:
  ohos:
    generate: true
    image_path: "assets/icons/your_start_icon_name.jpg"
    image_path_foreground: "assets/icons/your_foreground_name.jpg"
    image_path_background: "assets/icons/your_background_name.jpg"
```

行为：

- 输出文件名固定为：
  - `foreground.png`
  - `background.png`
  - `startIcon.png`（来源于 `image_path`）
- 输入文件名可任意（例如 `startIcon_open.jpg` / `foreground_hello.jpg` / `background_world.jpg`），不会影响输出标准命名。
- `foreground/background` 保持原始像素尺寸，不做缩放压缩。
- `module.json5` 中：
  - `icon -> $media:layered_image`
  - `startWindowIcon -> $media:startIcon`

## 支持的输入格式

工具通过解码图片字节内容处理输入，支持常见格式（如 `png/jpg/jpeg/webp`），最终统一输出为 `png` 资源文件。

## 执行命令

```bash
dart run flutter_launcher_icons
```

## 项目链接

- Homepage: https://github.com/star4277/flutter_launcher_icons_ohos
- Repository: https://github.com/star4277/flutter_launcher_icons_ohos
- Issues: https://github.com/star4277/flutter_launcher_icons_ohos/issues

## 致谢

感谢 Flutter Community 的 `flutter_launcher_icons` 原项目和所有贡献者。  
特别感谢原维护者 Mark O'Sullivan。
