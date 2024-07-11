import 'dart:convert';
import 'dart:html' as html;

import 'package:cm_2_git/models/kanban_board.dart';
import 'package:universal_html/html.dart';

Future<void> downloadFile(String text, String? name) async {
  final bytes = utf8.encode(text);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = '$name.json';
  html.document.body?.children.add(anchor);

// download
  anchor.click();

// cleanup
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}