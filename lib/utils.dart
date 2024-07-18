class Compute {
  static String dateFormat(DateTime timestamp) {
    // Time format: 11:58 pm
    DateTime time = timestamp.toLocal();
    return '${time.hour.remainder(60).toString().padLeft(2, '0')}:${time.minute.remainder(60).toString().padLeft(2, '0')} ${time.hour > 12 ? 'pm' : 'am'}';
  }
}
