import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SmxMenuVersion extends StatelessWidget {
  static Future<String>? _versionFuture;

  final TextStyle style;
  final TextAlign? textAlign;

  const SmxMenuVersion({super.key, required this.style, this.textAlign});

  static Future<String> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = info.version.trim();
    final buildNumber = info.buildNumber.trim();

    if (buildNumber.isNotEmpty && buildNumber != '0') {
      return 'Versión $version+$buildNumber';
    }

    return 'Versión $version';
  }

  @override
  Widget build(BuildContext context) {
    _versionFuture ??= _loadVersion();

    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? 'Versión',
          textAlign: textAlign,
          style: style,
        );
      },
    );
  }
}
