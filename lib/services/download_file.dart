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

Future<void> importJ(KanbanBoard kanbanBoard, _kanbanBoardScreenState) async {
  // HTML input element
  InputElement uploadInput = FileUploadInputElement() as InputElement
    ..accept = '*/json';
  uploadInput.click();

   uploadInput.onChange.listen(
    (changeEvent) {
      final file = uploadInput.files!.first;
      final reader = FileReader();

      reader.readAsText(file);

        reader.onLoadEnd.listen(
            // After file finish reading and loading, it will be uploaded to firebase storage
            (loadEndEvent) async {
          var json = reader.result;
          print(42);
          kanbanBoard = KanbanBoard.fromJson(jsonDecode(json.toString()));
          print(kanbanBoard);
          _kanbanBoardScreenState.setState(() {});
        });

    },
  );
}
