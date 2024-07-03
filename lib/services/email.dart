import 'package:cm_2_git/models/kanban_card.dart';
import 'package:url_launcher/url_launcher_string.dart';

void launchEmail(KanbanCard card) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: card.assignee,
    query:
        'mailto:${card.assignee}&subject= Card:${card.id}&body= Assigned to:${card.assignee} %0D%0A CARD: ${card.id} %0D%0A description: ${card.description}', // Add subject and body here
  );

  var url = params.toString();
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    print('Could not launch $url');
  }
}

void launchUrl(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    print('Could not launch $url');
  }
}
