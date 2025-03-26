String timeToISO(DateTime? dateTime) {
  dateTime ??= DateTime.now();
  return dateTime.toIso8601String();
}