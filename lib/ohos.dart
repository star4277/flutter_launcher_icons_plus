import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/utils.dart' as utils;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

/// Template for OHOS icon generation
class OhosIconTemplate {
  /// Creates an [OhosIconTemplate] with the given [size] and [fileName]
  OhosIconTemplate({
    required this.size,
    required this.fileName,
  });

  /// The file name for the icon
  final String fileName;

  /// The size of the icon in pixels
  final int size;
}

/// List of OHOS icon templates to generate
final List<OhosIconTemplate> singleImageOhosIcons = <OhosIconTemplate>[
  OhosIconTemplate(fileName: 'icon.png', size: 144),
];

/// List of OHOS icon templates to generate for layered icon mode.
final List<OhosIconTemplate> layeredOhosIcons = <OhosIconTemplate>[
  OhosIconTemplate(fileName: 'background.png', size: 144),
  OhosIconTemplate(fileName: 'foreground.png', size: 144),
];

final OhosIconTemplate _startWindowOhosIcon =
    OhosIconTemplate(fileName: 'startIcon.png', size: 144);

const String _layeredImageJsonContent = '''
{
  "layered-image":
  {
    "background" : "\$media:background",
    "foreground" : "\$media:foreground"
  }
}
''';

const String _singleIconMediaRef = r'$media:icon';
const String _singleAppScopeIconMediaRef = r'$media:icon';
const String _entryModuleJson5Path = 'ohos/entry/src/module.json5';
const String _mainModuleJson5Path = 'ohos/entry/src/main/module.json5';
const String _appScopeJson5Path = 'ohos/AppScope/app.json5';
const String _mainLayeredImageJsonPath =
    'ohos/entry/src/main/resources/base/media/layered_image.json';
const String _appScopeLayeredImageJsonPath =
    'ohos/AppScope/resources/base/media/layered_image.json';
const String _appScopeAppIconPath =
    'ohos/AppScope/resources/base/media/app_icon.png';
const String _appScopeIconPath = 'ohos/AppScope/resources/base/media/icon.png';
const String _entryMainIconPath =
    'ohos/entry/src/main/resources/base/media/icon.png';
const String _appScopeBackgroundPath =
    'ohos/AppScope/resources/base/media/background.png';
const String _appScopeForegroundPath =
    'ohos/AppScope/resources/base/media/foreground.png';
const String _entryMainBackgroundPath =
    'ohos/entry/src/main/resources/base/media/background.png';
const String _entryMainForegroundPath =
    'ohos/entry/src/main/resources/base/media/foreground.png';
const String _entryMainStartIconPath =
    'ohos/entry/src/main/resources/base/media/startIcon.png';

/// Creates OHOS launcher icons based on the provided [config] and [flavor]
Future<void> createIcons(Config config, String? flavor) async {
  utils.printStatus('Creating default icons for OHOS');
  final String? foregroundFilePath = config.getImagePathOhosForeground();
  final String? backgroundFilePath = config.getImagePathOhosBackground();
  final bool hasLayeredPaths =
      foregroundFilePath != null && backgroundFilePath != null;

  if (hasLayeredPaths) {
    final foreground = await utils.decodeImageFile(foregroundFilePath);
    final background = await utils.decodeImageFile(backgroundFilePath);
    if (foreground == null || background == null) {
      return;
    }
    final String? startWindowFilePath = config.getImagePathOhos();
    if (startWindowFilePath == null) {
      throw const InvalidConfigException(constants.errorMissingImagePath);
    }
    final startWindowImage = await utils.decodeImageFile(startWindowFilePath);
    if (startWindowImage == null) {
      return;
    }

    utils.printStatus(
      'Overwriting the default OHOS launcher icon with layered icons',
    );
    await Future.wait(<Future<void>>[
      _copyLayeredIconWithoutResize(
        sourceImage: background,
        fileName: layeredOhosIcons[0].fileName,
      ),
      _copyLayeredIconWithoutResize(
        sourceImage: foreground,
        fileName: layeredOhosIcons[1].fileName,
      ),
    ]);

    await overwriteExistingIcons(
      _startWindowOhosIcon,
      startWindowImage,
      flavor,
      targetPaths: <String>[
        _entryMainStartIconPath,
      ],
    );
    await _deleteFilesIfExists(<String>[
      _appScopeIconPath,
      _entryMainIconPath,
    ]);
    await _createLayeredImageJsonIfNeeded();
    await _replaceStartWindowIconRef(r'$media:startIcon');
    await _replaceAbilityIconOnlyRef(r'$media:layered_image');
    await _replaceAppScopeIconRef(r'$media:layered_image');
    return;
  }

  final String? filePath = config.getImagePathOhos();
  if (filePath == null) {
    throw const InvalidConfigException(constants.errorMissingImagePath);
  }
  Image? image = await utils.decodeImageFile(filePath);
  if (image == null) {
    return;
  }
  if (config.backgroundColorOhos != null && image.hasAlpha) {
    final backgroundColor = _getBackgroundColor(config);
    final pixel = image.getPixel(0, 0);
    do {
      pixel.set(_alphaBlend(pixel, backgroundColor));
    } while (pixel.moveNext());

    image = image.convert(numChannels: 3);
  }

  utils.printStatus(
    'Overwriting the default OHOS launcher icon with a new icon',
  );
  final concurrentIconUpdates = <Future<void>>[];
  for (OhosIconTemplate template in singleImageOhosIcons) {
    concurrentIconUpdates.add(
      overwriteExistingIcons(
        template,
        image,
        flavor,
      ),
    );
  }
  await Future.wait(concurrentIconUpdates);
  await _deleteFilesIfExists(<String>[
    _appScopeAppIconPath,
    _appScopeBackgroundPath,
    _appScopeForegroundPath,
    _entryMainBackgroundPath,
    _entryMainForegroundPath,
    _entryMainStartIconPath,
  ]);
  await _deleteLayeredImageJsonIfExists();
  await _replaceAbilityIconRefs(_singleIconMediaRef);
  await _replaceAppScopeIconRef(_singleAppScopeIconMediaRef);
}

/// Overwrites existing OHOS icons with the provided [template] and [image]
Future<void> overwriteExistingIcons(
  OhosIconTemplate template,
  Image image,
  String? flavor, {
  List<String>? targetPaths,
}) async {
  final Image newFile = utils.createResizedImage(template.size, image);

  const String ohosProjectPath = 'ohos';

  final List<String> defaultTargetPaths = <String>[
    path.join(
      ohosProjectPath,
      'AppScope',
      'resources',
      'base',
      'media',
      template.fileName,
    ),
    path.join(
      ohosProjectPath,
      'entry',
      'src',
      'main',
      'resources',
      'base',
      'media',
      template.fileName,
    ),
  ];

  for (final targetPath in targetPaths ?? defaultTargetPaths) {
    final pngFile = await File(targetPath).create(recursive: true);
    await pngFile.writeAsBytes(encodePng(newFile));
  }
}

Future<void> _createLayeredImageJsonIfNeeded() async {
  for (final targetPath in <String>[
    _mainLayeredImageJsonPath,
    _appScopeLayeredImageJsonPath
  ]) {
    final file = File(targetPath);
    if (file.existsSync()) {
      continue;
    }
    await file.create(recursive: true);
    await file.writeAsString(_layeredImageJsonContent);
  }
}

Future<void> _deleteLayeredImageJsonIfExists() async {
  for (final targetPath in <String>[
    _mainLayeredImageJsonPath,
    _appScopeLayeredImageJsonPath
  ]) {
    final file = File(targetPath);
    if (!file.existsSync()) {
      continue;
    }
    await file.delete();
  }
}

Future<void> _replaceAbilityIconRefs(String iconMediaRef) async {
  for (final modulePath in <String>[
    _entryModuleJson5Path,
    _mainModuleJson5Path,
  ]) {
    final moduleFile = File(modulePath);
    if (!moduleFile.existsSync()) {
      continue;
    }
    final content = await moduleFile.readAsString();
    final updated = content
        .replaceAll(
          RegExp(r'"icon"\s*:\s*"\$media:[^"]+"'),
          '"icon": "$iconMediaRef"',
        )
        .replaceAll(
          RegExp(r'"startWindowIcon"\s*:\s*"\$media:[^"]+"'),
          '"startWindowIcon": "$iconMediaRef"',
        );
    if (updated != content) {
      await moduleFile.writeAsString(updated);
    }
  }
}

Future<void> _alignAbilityIconWithStartWindowIcon() async {
  for (final modulePath in <String>[
    _entryModuleJson5Path,
    _mainModuleJson5Path,
  ]) {
    final moduleFile = File(modulePath);
    if (!moduleFile.existsSync()) {
      continue;
    }
    final content = await moduleFile.readAsString();
    final startWindowMatch = RegExp(
      r'"startWindowIcon"\s*:\s*"(\$media:[^"]+)"',
    ).firstMatch(content);
    final startWindowRef = startWindowMatch?.group(1);
    if (startWindowRef == null) {
      continue;
    }
    final updated = content.replaceAll(
      RegExp(r'"icon"\s*:\s*"\$media:[^"]+"'),
      '"icon": "$startWindowRef"',
    );
    if (updated != content) {
      await moduleFile.writeAsString(updated);
    }
  }
}

Future<void> _replaceAbilityIconOnlyRef(String iconMediaRef) async {
  for (final modulePath in <String>[
    _entryModuleJson5Path,
    _mainModuleJson5Path,
  ]) {
    final moduleFile = File(modulePath);
    if (!moduleFile.existsSync()) {
      continue;
    }
    final content = await moduleFile.readAsString();
    final updated = content.replaceAll(
      RegExp(r'"icon"\s*:\s*"\$media:[^"]+"'),
      '"icon": "$iconMediaRef"',
    );
    if (updated != content) {
      await moduleFile.writeAsString(updated);
    }
  }
}

Future<void> _replaceStartWindowIconRef(String iconMediaRef) async {
  for (final modulePath in <String>[
    _entryModuleJson5Path,
    _mainModuleJson5Path,
  ]) {
    final moduleFile = File(modulePath);
    if (!moduleFile.existsSync()) {
      continue;
    }
    final content = await moduleFile.readAsString();
    final updated = content.replaceAll(
      RegExp(r'"startWindowIcon"\s*:\s*"\$media:[^"]+"'),
      '"startWindowIcon": "$iconMediaRef"',
    );
    if (updated != content) {
      await moduleFile.writeAsString(updated);
    }
  }
}

Future<void> _replaceAppScopeIconRef(String iconMediaRef) async {
  final appScopeFile = File(_appScopeJson5Path);
  if (!appScopeFile.existsSync()) {
    return;
  }
  final content = await appScopeFile.readAsString();
  final updated = content.replaceAll(
    RegExp(r'"icon"\s*:\s*"\$media:[^"]+"'),
    '"icon": "$iconMediaRef"',
  );
  if (updated != content) {
    await appScopeFile.writeAsString(updated);
  }
}

Future<void> _deleteFilesIfExists(List<String> paths) async {
  for (final filePath in paths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }
    await file.delete();
  }
}

Future<void> _copyLayeredIconWithoutResize({
  required Image sourceImage,
  required String fileName,
}) async {
  final bytes = encodePng(sourceImage);
  final targetPaths = <String>[
    path.join('ohos', 'AppScope', 'resources', 'base', 'media', fileName),
    path.join(
      'ohos',
      'entry',
      'src',
      'main',
      'resources',
      'base',
      'media',
      fileName,
    ),
  ];
  for (final targetPath in targetPaths) {
    final target = File(targetPath);
    await target.parent.create(recursive: true);
    await target.writeAsBytes(bytes);
  }
}

ColorUint8 _getBackgroundColor(Config config) {
  final backgroundColorHex = config.backgroundColorOhos!.startsWith('#')
      ? config.backgroundColorOhos!.substring(1)
      : config.backgroundColorOhos!;
  if (backgroundColorHex.length != 6) {
    throw Exception('background_color_ios hex should be 6 characters long');
  }

  final backgroundByte = int.parse(backgroundColorHex, radix: 16);
  return ColorUint8.rgba(
    (backgroundByte >> 16) & 0xff,
    (backgroundByte >> 8) & 0xff,
    (backgroundByte >> 0) & 0xff,
    0xff,
  );
}

Color _alphaBlend(Color fg, ColorUint8 bg) {
  if (fg.format != Format.uint8) {
    fg = fg.convert(format: Format.uint8);
  }
  if (fg.a == 0) {
    return bg;
  } else {
    final invAlpha = 0xff - fg.a;
    return ColorUint8.rgba(
      (fg.a * fg.r + invAlpha * bg.g) ~/ 0xff,
      (fg.a * fg.g + invAlpha * bg.a) ~/ 0xff,
      (fg.a * fg.b + invAlpha * bg.b) ~/ 0xff,
      0xff,
    );
  }
}
