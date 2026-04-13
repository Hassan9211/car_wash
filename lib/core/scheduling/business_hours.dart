import 'package:flutter/material.dart';

class BusinessHours {
  BusinessHours._();

  static const openingTime = TimeOfDay(hour: 9, minute: 0);
  static const closingTime = TimeOfDay(hour: 17, minute: 0);
  static const label = '9:00 AM - 5:00 PM';
  static const defaultBookingTimeLabel = '05:00 PM';

  static const timeSlotLabels = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  static bool isWithinBusinessHours(TimeOfDay time) {
    final minutes = _toMinutes(time);
    return minutes >= _toMinutes(openingTime) &&
        minutes <= _toMinutes(closingTime);
  }

  static String normalizeBookingTimeLabel(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (timeSlotLabels.contains(trimmedValue)) {
      return trimmedValue;
    }

    return defaultBookingTimeLabel;
  }

  static int _toMinutes(TimeOfDay time) => (time.hour * 60) + time.minute;
}
