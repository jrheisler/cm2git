import 'package:intl/intl.dart';

String convertMilliToDateTime(int milliseconds)   {
  // Convert millisecondsSinceEpoch to DateTime
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  // Format DateTime to a readable string
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

  return formattedDate; // Output: 2024-06-25 – 14:22 (example output)
}
