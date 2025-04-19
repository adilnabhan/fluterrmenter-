import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

extension StringXExtension on String {
  String get amPm {
    try {
      // Parse the time string "00:00:00" to DateTime
      final timeString = split(':').take(2).join(':'); // Get "00:00" part
      final dateTime = DateFormat('HH:mm').parse(timeString);

      // Convert to 12-hour format with AM/PM
      return DateFormat('hh:mm a').format(dateTime); // Returns "00:00 AM"
    } catch (e) {
      write(e.toString());
      return this;
    }
  }
}

///* This for split the address
String cleanAddress(String address) {
  // Remove pincode (any 6-digit number)
  address = address.replaceAll(RegExp(r'\b\d{6}\b'), '');
  final parts = address.split(',').map((e) => e.trim()).toList();
  if (parts.length > 2) {
    parts.removeRange(parts.length - 2, parts.length);
  }
  return parts.join(', ').trim();
}
