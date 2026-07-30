import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxApis/smxConfig.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        _DocumentationLink(style: style),
        const SizedBox(height: 8),
        FutureBuilder<String>(
          future: _versionFuture,
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Versión',
              textAlign: textAlign,
              style: style,
            );
          },
        ),
      ],
    );
  }
}

class _DocumentationLink extends StatelessWidget {
  final TextStyle style;

  const _DocumentationLink({required this.style});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: _openDocumentation,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, color: style.color, size: 15),
              const SizedBox(width: 6),
              Text(
                'Conocer ${SmxConfig.titulo}',
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: style.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDocumentation() {
    final path = kDebugMode ? 'documents/htmls/docu.html' : 'docu.html';
    final uri = Uri.base.resolve(path);
    html.window.sessionStorage['saldify_documentation_return_url'] = Uri.base
        .toString();
    html.window.location.assign(uri.toString());
  }
}
