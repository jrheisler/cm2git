import 'package:cm_2_git/models/kanban_card.dart';
import 'package:url_launcher/url_launcher.dart';

void launchEmail(KanbanCard card) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: card.title,
    query: 'subject= Card:${card.id}&body= Assigned to:${card.assignee} CARD: ${card.id} description: ${card.description}', // Add subject and body here
  );

  var url = params.toString();
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}