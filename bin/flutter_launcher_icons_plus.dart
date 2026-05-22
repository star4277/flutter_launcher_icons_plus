import 'package:flutter_launcher_icons_plus/constants.dart';
import 'package:flutter_launcher_icons_plus/main.dart' as launcher_icons;
import 'package:flutter_launcher_icons_plus/src/version.dart';

void main(List<String> arguments) {
  print(introMessage(packageVersion));
  launcher_icons.createIconsFromArguments(arguments);
}