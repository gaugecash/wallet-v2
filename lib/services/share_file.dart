import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

Future<void> shareFile(String contents, BuildContext context) {
  if (kIsWeb) {
    _shareFileWeb(contents);
    return Future.value();
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    return _shareFileMobile(contents, context);
  }

  if (!kIsWeb && Platform.isLinux) {
    return Future.value();
  }

  throw UnimplementedError('Unknown platform: ${kIsWeb ? "Web" : Platform.operatingSystem}');
}

void _shareFileWeb(String contents) {
  final codes = utf8.encode(contents);
  final content = base64Encode(codes);
  html.AnchorElement(
    href: 'data:application/octet-stream;charset=utf-8;base64,$content',
  )
    ..setAttribute('download', 'gau_key.txt')
    ..click();
}

Future<void> _shareFileMobile(String contents, BuildContext context) async {
  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}/gau_key.txt';
  final file = File(path);
  await file.writeAsString(contents);

  final box = context.findRenderObject() as RenderBox?;

  await Share.shareXFiles(
    [XFile(path, mimeType: 'text/plain')],
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}
