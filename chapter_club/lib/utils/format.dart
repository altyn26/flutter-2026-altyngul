const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatTime(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDay(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

String formatDate(DateTime date) {
  final month = _months[date.month - 1];
  return '${date.day} $month, ${formatTime(date.hour, date.minute)}';
}
