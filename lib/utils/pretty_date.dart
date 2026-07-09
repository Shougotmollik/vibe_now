part of '../utils.dart';

List<String> localizedMonths(BuildContext? context) {
  final loc = context != null ? AppLocalizations.of(context) : null;
  return [
    loc?.translate('jan') ?? 'Jan',
    loc?.translate('feb') ?? 'Feb',
    loc?.translate('mar') ?? 'Mar',
    loc?.translate('apr') ?? 'Apr',
    loc?.translate('may') ?? 'May',
    loc?.translate('jun') ?? 'Jun',
    loc?.translate('jul') ?? 'Jul',
    loc?.translate('aug') ?? 'Aug',
    loc?.translate('sep') ?? 'Sep',
    loc?.translate('oct') ?? 'Oct',
    loc?.translate('nov') ?? 'Nov',
    loc?.translate('dec') ?? 'Dec',
  ];
}

String prettyDate(int timestamp, {BuildContext? context}) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final months = localizedMonths(context);
  final loc = context != null ? AppLocalizations.of(context) : null;

  int hour = date.hour;
  if (hour > 12) {
    hour -= 12;
  }

  if (hour == 0) {
    hour = 12;
  }

  return '${date.day} ${months[date.month - 1]} ${date.year - 2000}, ${hour < 10 ? '0${hour}' : hour} : ${date.minute < 10 ? '0${date.minute}' : date.minute} ${date.hour < 12 ? (loc?.translate('am') ?? 'AM') : (loc?.translate('pm') ?? 'PM')}';
}

String timeAgo(DateTime timestamp, {bool showMinuteAndHour = false, BuildContext? context}) {
  final loc = context != null ? AppLocalizations.of(context) : null;
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  final months = localizedMonths(context);
  final String minuteAndHour =
      '${timestamp.hour < 12 ? timestamp.hour + 1 : timestamp.hour - 11}:${timestamp.minute} ${timestamp.hour < 12 ? (loc?.translate('am') ?? 'AM') : (loc?.translate('pm') ?? 'PM')}';
  if (difference.inSeconds < 60) {
    return loc?.translate('justNow') ?? 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} ${loc?.translate('minAgo') ?? 'min ago'}';
  } else if (difference.inHours < 24) {
    if (difference.inHours < 4) {
      final hourKey = difference.inHours == 1 ? 'hourAgo' : 'hoursAgo';
      return '${difference.inHours} ${loc?.translate(hourKey) ?? (difference.inHours == 1 ? 'hour ago' : 'hours ago')}';
    } else {
      if (now.day == timestamp.day) {
        return '$minuteAndHour';
      } else {
        return '${loc?.translate('yesterday') ?? 'yesterday'}, ${minuteAndHour}';
      }
    }
  } else if (difference.inDays < 1) {
    return loc?.translate('yesterday') ?? 'yesterday';
  } else {
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year - 2000}${showMinuteAndHour ? ', $minuteAndHour' : ''}';
  }
}
