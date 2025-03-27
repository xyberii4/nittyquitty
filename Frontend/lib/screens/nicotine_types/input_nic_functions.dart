String timeToISO(DateTime? dateTime) {
  dateTime ??= DateTime.now();
  String iso = dateTime.toIso8601String();
  print(iso);
  return iso;
}