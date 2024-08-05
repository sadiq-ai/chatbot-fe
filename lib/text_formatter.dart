// Text Formatter

import 'package:flutter/services.dart';

class TextFormatter {
  static String expiryDate(String expiryDate) {
    if (expiryDate.length == 4) {
      return expiryDate.replaceRange(2, 2, '/');
    } else {
      return expiryDate;
    }
  }

  static String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]+'), '');
  }

  static String firebaseError(String input) {
    return input.toString().split('. ')[0].trim();
  }

  static String errorFormatter({required String text}) {
    // Error messages Formatting
    text = text.split(' or ')[0];
    text = "${text.split(".")[0]}.";
    text = text.replaceAll('String', 'Field');
    text = text.replaceAll('null', 'blank');
    text = text.replaceAll('badly', 'incorrectly');
    text = text.replaceAll('identifier', 'email');
    return text;
  }

  static String capitalisedFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  static String enumRemover(String enumText) {
    String text = enumText.replaceAll('_', ' ');
    return capitalisedFirst(text);
  }

  static String dateTimeFormat(DateTime date, {bool short = false}) {
    date = date.toLocal();
    List<String> months = <String>[
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
    String amPm = 'AM';
    int hour = date.hour;
    if (hour == 12) {
      amPm = 'PM';
    } else if (hour > 12) {
      hour = hour - 12;
      amPm = 'PM';
    }
    if (short) return '${date.day}/${date.month}/${date.year}';
    return '${date.day}${date.day == 1 || date.day == 21 || date.day == 31 ? 'st' : date.day == 2 || date.day == 22 ? 'nd' : date.day == 3 || date.day == 23 ? 'rd' : 'th'} ${months[date.month - 1]} ${date.year} - ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String dateFormat(DateTime? date, {bool short = false}) {
    if (date == null) return 'To be assigned';
    date = date.toLocal();
    List<String> months = <String>[
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
    if (short) return '${date.day}/${date.month}/${date.year}';
    return '${date.day}${date.day == 1 || date.day == 21 || date.day == 31 ? 'st' : date.day == 2 || date.day == 22 ? 'nd' : date.day == 3 || date.day == 23 ? 'rd' : 'th'} ${months[date.month - 1]} ${date.year}';
  }

  static String timeFormat(DateTime date) {
    date = date.toLocal();
    // AM/PM
    String amPm = 'AM';
    int hour = date.hour;
    if (hour == 12) {
      amPm = 'PM';
    } else if (hour > 12) {
      hour = hour - 12;
      amPm = 'PM';
    }
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String getTimeString(DateTime timestamp) {
    final Duration timeAgo = DateTime.now().difference(timestamp);

    if (timeAgo.inSeconds < 60) {
      return 'Just now';
    } else if (timeAgo.inMinutes < 60) {
      return '${timeAgo.inMinutes}m';
    } else if (timeAgo.inHours < 24) {
      return '${timeAgo.inHours}h';
    } else {
      return '${timeAgo.inDays}d';
    }
  }

  static String getTimeStringFull(DateTime timestamp) {
    final Duration timeAgo = DateTime.now().difference(timestamp);

    if (timeAgo.inSeconds < 60) {
      if (timeAgo.inSeconds == 1) {
        return '${timeAgo.inSeconds} sec ago';
      } else {
        return '${timeAgo.inSeconds} sec ago';
      }
    } else if (timeAgo.inMinutes < 60) {
      if (timeAgo.inMinutes == 1) {
        return '${timeAgo.inMinutes} min ago';
      } else {
        return '${timeAgo.inMinutes} min ago';
      }
    } else if (timeAgo.inHours < 24) {
      if (timeAgo.inHours == 1) {
        return '${timeAgo.inHours} hr ago';
      } else {
        return '${timeAgo.inHours} hrs ago';
      }
    } else if (timeAgo.inDays < 30) {
      if (timeAgo.inDays == 1) {
        return '${timeAgo.inDays} day ago';
      } else {
        return '${timeAgo.inDays} days ago';
      }
    } else if (timeAgo.inDays < 365) {
      int months = (timeAgo.inDays / 30).floor();
      if (months == 1) {
        return '$months mon ago';
      } else {
        return '$months mons ago';
      }
    } else {
      int years = (timeAgo.inDays / 365).floor();
      if (years == 1) {
        return '$years yr ago';
      } else {
        return '$years yrs ago';
      }
    }
  }

  static String getNumberString(num number, {bool isShort = true}) {
    if (isShort == false) {
      if (number >= 1000000) {
        // Format number in millions (M)
        double numInMillions = number / 1000000;
        if (numInMillions.toString().split('.')[1] == '0') {
          return '${numInMillions.toStringAsFixed(0)}M';
        }
        return '${numInMillions.toStringAsFixed(1)}M';
      } else if (number >= 100000) {
        // Format number in thousands (K)
        double numInThousands = number / 1000;
        if (numInThousands.toString().split('.')[1] == '0') {
          return '${numInThousands.toStringAsFixed(0)}K';
        }
        return '${numInThousands.toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    }
    if (number >= 1000000) {
      // Format number in millions (M)
      double numInMillions = number / 1000000;
      if (numInMillions.toString().split('.')[1] == '0') {
        return '${numInMillions.toStringAsFixed(0)}M';
      }
      return '${numInMillions.toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      // Format number in thousands (K)
      double numInThousands = number / 1000;
      if (numInThousands.toString().split('.')[1] == '0') {
        return '${numInThousands.toStringAsFixed(0)}K';
      }
      return '${numInThousands.toStringAsFixed(1)}K';
    } else {
      // For numbers less than 1000, return as it is
      return number.toString();
    }
  }

  static String getTimeAgo(DateTime dateTime, {bool numericDates = true}) {
    final DateTime date2 = DateTime.now();
    final Duration difference = date2.difference(dateTime);

    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays}d';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes}m';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1m' : 'A min ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds}s';
    } else {
      return 'Now';
    }
  }
}

// Custom Formatter
class MyCustomFormatter extends TextInputFormatter {
  MyCustomFormatter({required this.sample, required this.separator});
  final String sample;
  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > sample.length) {
          return oldValue;
        }
        if (newValue.text.length < sample.length &&
            sample[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection:
                TextSelection.collapsed(offset: newValue.selection.end + 1),
          );
        }
      }
    }
    return newValue;
  }
}
