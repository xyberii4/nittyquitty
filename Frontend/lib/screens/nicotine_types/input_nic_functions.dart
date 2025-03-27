String timeToISO(DateTime? dateTime) {
  dateTime ??= DateTime.now();
  return dateTime.toUtc().toIso8601String();
}

bool isValidTime(String input) {
  final RegExp timeRegex = RegExp(r'^(?:[01]?\d|2[0-3]):[0-5]\d$'); // Matches 00:00 - 23:59
  return timeRegex.hasMatch(input);
}