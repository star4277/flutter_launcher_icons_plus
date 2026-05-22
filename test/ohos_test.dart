import 'dart:io';

import 'package:flutter_launcher_icons/config/config.dart';
import 'package:flutter_launcher_icons/ohos.dart' as ohos;
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('OHOS icons', () {
    final String testDir =
        path.join('.dart_tool', 'flutter_launcher_icons', 'test', 'ohos_icons');
    late String currentDirectory;

    setUp(() async {
      currentDirectory = Directory.current.path;
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      await Directory(testDir).create(recursive: true);
      Directory.current = testDir;
    });

    tearDown(() {
      Directory.current = currentDirectory;
    });

    test('single image mode deletes layered_image.json and updates module refs',
        () async {
      _prepareCommonOhosStructure();
      _writeModuleJson5(
        filePath: 'ohos/entry/src/module.json5',
        iconRef: r'$media:layered_image',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeModuleJson5(
        filePath: 'ohos/entry/src/main/module.json5',
        iconRef: r'$media:layered_image',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeModuleJson5(
        filePath: 'ohos/entry/src/ohosTest/module.json5',
        iconRef: r'$media:layered_image',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeAppScopeJson5(iconRef: r'$media:layered_image');
      await _writeLayeredImageJsonFiles();
      await _writeImage('ohos/AppScope/resources/base/media/background.png');
      await _writeImage('ohos/AppScope/resources/base/media/foreground.png');
      await _writeImage(
          'ohos/entry/src/main/resources/base/media/background.png');
      await _writeImage(
          'ohos/entry/src/main/resources/base/media/foreground.png');
      await _writeImage(
          'ohos/entry/src/ohosTest/resources/base/media/background.png');
      await _writeImage(
          'ohos/entry/src/ohosTest/resources/base/media/foreground.png');
      await _writeImage(
          'ohos/entry/src/main/resources/base/media/startIcon.png');
      await _writeImage(
          'ohos/entry/src/ohosTest/resources/base/media/startIcon.png');
      await _writeImage('assets/icon.png');

      final config = Config.fromJson(<String, dynamic>{
        'ohos': true,
        'image_path': 'assets/icon.png',
      });

      await ohos.createIcons(config, null);

      expect(
          File('ohos/entry/src/main/resources/base/media/icon.png')
              .existsSync(),
          isTrue);
      expect(File('ohos/AppScope/resources/base/media/icon.png').existsSync(),
          isTrue);
      expect(
          File('ohos/AppScope/resources/base/media/app_icon.png').existsSync(),
          isFalse);
      expect(
          File('ohos/entry/src/main/resources/base/media/background.png')
              .existsSync(),
          isFalse);
      expect(
          File('ohos/entry/src/main/resources/base/media/foreground.png')
              .existsSync(),
          isFalse);
      expect(
          File('ohos/entry/src/ohosTest/resources/base/media/background.png')
              .existsSync(),
          isTrue);
      expect(
          File('ohos/entry/src/ohosTest/resources/base/media/foreground.png')
              .existsSync(),
          isTrue);
      expect(
          File('ohos/entry/src/main/resources/base/media/startIcon.png')
              .existsSync(),
          isFalse);
      expect(
          File('ohos/entry/src/ohosTest/resources/base/media/startIcon.png')
              .existsSync(),
          isTrue);
      expect(
        File('ohos/entry/src/main/resources/base/media/layered_image.json')
            .existsSync(),
        isFalse,
      );
      expect(
        File('ohos/AppScope/resources/base/media/layered_image.json')
            .existsSync(),
        isFalse,
      );
      final mainModule =
          File('ohos/entry/src/main/module.json5').readAsStringSync();
      final entryModule =
          File('ohos/entry/src/module.json5').readAsStringSync();
      final ohosTestModule =
          File('ohos/entry/src/ohosTest/module.json5').readAsStringSync();
      final appScope = File('ohos/AppScope/app.json5').readAsStringSync();
      expect(mainModule.contains(r'"icon": "$media:icon"'), isTrue);
      expect(mainModule.contains(r'"startWindowIcon": "$media:icon"'), isTrue);
      expect(entryModule.contains(r'"icon": "$media:icon"'), isTrue);
      expect(entryModule.contains(r'"startWindowIcon": "$media:icon"'), isTrue);
      expect(
          ohosTestModule.contains(r'"icon": "$media:layered_image"'), isTrue);
      expect(ohosTestModule.contains(r'"startWindowIcon": "$media:startIcon"'),
          isTrue);
      expect(appScope.contains(r'"icon": "$media:icon"'), isTrue);
    });

    test(
        'layered image mode creates layered_image.json and updates module refs',
        () async {
      _prepareCommonOhosStructure();
      _writeModuleJson5(
        filePath: 'ohos/entry/src/module.json5',
        iconRef: r'$media:icon',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeModuleJson5(
        filePath: 'ohos/entry/src/main/module.json5',
        iconRef: r'$media:icon',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeModuleJson5(
        filePath: 'ohos/entry/src/ohosTest/module.json5',
        iconRef: r'$media:icon',
        startWindowIconRef: r'$media:startIcon',
      );
      _writeAppScopeJson5(iconRef: r'$media:icon');
      await _writeImage('ohos/AppScope/resources/base/media/icon.png');
      await _writeImage('ohos/AppScope/resources/base/media/app_icon.png');
      await _writeImage('ohos/entry/src/main/resources/base/media/icon.png');
      await _writeImage(
          'ohos/entry/src/ohosTest/resources/base/media/icon.png');
      await _writeJpgWithSize(
        'assets/foreground_hello.jpg',
        width: 37,
        height: 53,
        color: ColorRgb8(255, 0, 0),
      );
      await _writeJpgWithSize(
        'assets/background_world.jpg',
        width: 45,
        height: 61,
        color: ColorRgb8(0, 0, 255),
      );
      await _writeJpgWithSize(
        'assets/startIcon_open.jpg',
        width: 40,
        height: 40,
        color: ColorRgb8(0, 255, 0),
      );

      final config = Config.fromJson(<String, dynamic>{
        'ohos': true,
        'image_path': 'assets/startIcon_open.jpg',
        'image_path_ohos_foreground': 'assets/foreground_hello.jpg',
        'image_path_ohos_background': 'assets/background_world.jpg',
      });

      await ohos.createIcons(config, null);

      expect(
        File('ohos/entry/src/main/resources/base/media/foreground.png')
            .existsSync(),
        isTrue,
      );
      expect(
        _imageSize('ohos/entry/src/main/resources/base/media/foreground.png'),
        equals('37x53'),
      );
      expect(
        File('ohos/entry/src/main/resources/base/media/background.png')
            .existsSync(),
        isTrue,
      );
      expect(
        _imageSize('ohos/entry/src/main/resources/base/media/background.png'),
        equals('45x61'),
      );
      expect(
        File('ohos/entry/src/main/resources/base/media/layered_image.json')
            .existsSync(),
        isTrue,
      );
      expect(
        File('ohos/entry/src/main/resources/base/media/startIcon.png')
            .existsSync(),
        isTrue,
      );
      expect(
        _pixelAt('ohos/entry/src/main/resources/base/media/startIcon.png').g,
        equals(255),
      );
      expect(
        File('ohos/entry/src/ohosTest/resources/base/media/startIcon.png')
            .existsSync(),
        isFalse,
      );
      expect(
        File('ohos/AppScope/resources/base/media/app_icon.png').existsSync(),
        isTrue,
      );
      expect(
        File('ohos/entry/src/main/resources/base/media/icon.png').existsSync(),
        isFalse,
      );
      expect(
        File('ohos/AppScope/resources/base/media/icon.png').existsSync(),
        isFalse,
      );
      expect(
        File('ohos/entry/src/ohosTest/resources/base/media/icon.png')
            .existsSync(),
        isTrue,
      );
      expect(
        File('ohos/AppScope/resources/base/media/layered_image.json')
            .existsSync(),
        isTrue,
      );
      final mainModule =
          File('ohos/entry/src/main/module.json5').readAsStringSync();
      final entryModule =
          File('ohos/entry/src/module.json5').readAsStringSync();
      final ohosTestModule =
          File('ohos/entry/src/ohosTest/module.json5').readAsStringSync();
      final appScope = File('ohos/AppScope/app.json5').readAsStringSync();
      expect(mainModule.contains(r'"icon": "$media:layered_image"'), isTrue);
      expect(
        mainModule.contains(r'"startWindowIcon": "$media:startIcon"'),
        isTrue,
      );
      expect(ohosTestModule.contains(r'"icon": "$media:icon"'), isTrue);
      expect(
        ohosTestModule.contains(r'"startWindowIcon": "$media:startIcon"'),
        isTrue,
      );
      expect(entryModule.contains(r'"icon": "$media:layered_image"'), isTrue);
      expect(entryModule.contains(r'"startWindowIcon": "$media:startIcon"'),
          isTrue);
      expect(appScope.contains(r'"icon": "$media:layered_image"'), isTrue);
    });
  });
}

void _writeAppScopeJson5({
  required String iconRef,
}) {
  final file = File('ohos/AppScope/app.json5');
  file.parent.createSync(recursive: true);
  file.createSync(recursive: true);
  file.writeAsStringSync('''
{
  "app": {
    "icon": "$iconRef"
  }
}
''');
}

void _prepareCommonOhosStructure() {
  Directory('ohos/AppScope/resources/base/media').createSync(recursive: true);
  Directory('ohos/entry/src/main/resources/base/media')
      .createSync(recursive: true);
  Directory('ohos/entry/src/ohosTest/resources/base/media')
      .createSync(recursive: true);
  Directory('ohos/entry/src/main').createSync(recursive: true);
  Directory('ohos/entry/src/ohosTest').createSync(recursive: true);
}

void _writeModuleJson5({
  required String filePath,
  required String iconRef,
  required String startWindowIconRef,
}) {
  final file = File(filePath);
  file.parent.createSync(recursive: true);
  file.createSync(recursive: true);
  file.writeAsStringSync('''
{
  "module": {
    "abilities": [
      {
        "icon": "$iconRef",
        "startWindowIcon": "$startWindowIconRef"
      }
    ]
  }
}
''');
}

Future<void> _writeLayeredImageJsonFiles() async {
  final main =
      File('ohos/entry/src/main/resources/base/media/layered_image.json');
  main.parent.createSync(recursive: true);
  main.createSync(recursive: true);
  main.writeAsStringSync(
      '{"layered-image":{"background":"\$media:background","foreground":"\$media:foreground"}}');
  final appScope =
      File('ohos/AppScope/resources/base/media/layered_image.json');
  appScope.parent.createSync(recursive: true);
  appScope.createSync(recursive: true);
  appScope.writeAsStringSync(
      '{"layered-image":{"background":"\$media:background","foreground":"\$media:foreground"}}');
}

Future<void> _writeImage(String filePath, {ColorRgb8? color}) async {
  await _writeImageWithColor(filePath, color ?? ColorRgb8(255, 0, 0));
}

Future<void> _writeImageWithColor(String filePath, ColorRgb8 color) async {
  await _writeImageWithSize(filePath, width: 32, height: 32, color: color);
}

Future<void> _writeImageWithSize(
  String filePath, {
  required int width,
  required int height,
  required ColorRgb8 color,
}) async {
  final image = Image(width: width, height: height);
  fill(image, color: color);
  final bytes = encodePng(image);
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
}

Future<void> _writeJpgWithSize(
  String filePath, {
  required int width,
  required int height,
  required ColorRgb8 color,
}) async {
  final image = Image(width: width, height: height);
  fill(image, color: color);
  final bytes = encodeJpg(image);
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
}

Pixel _pixelAt(String filePath) {
  final image = decodePng(File(filePath).readAsBytesSync())!;
  return image.getPixel(0, 0);
}

String _imageSize(String filePath) {
  final image = decodePng(File(filePath).readAsBytesSync())!;
  return '${image.width}x${image.height}';
}
