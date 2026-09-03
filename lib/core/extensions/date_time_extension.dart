import 'package:intl/intl.dart';

extension DateTimeXExtension on DateTime {
  String get ddMMM => DateFormat('dd MMM').format(toLocal()); // 01 Jan
  String get dd => DateFormat('dd').format(toLocal()); // 01
  String get ddMMMMYYYY => DateFormat('dd MMMM yyyy').format(toLocal()); // 01 January 2022
  String get ddMMMYYYY => DateFormat('dd MMM yyyy').format(toLocal()); // 01 Jan 2022
  String get mmmYYYY => DateFormat('MMM yyyy').format(toLocal()); // Jan 2022
  String get yyyyMMDDslash => DateFormat('yyyy/MM/dd').format(toLocal()); // 2022/01/01

  String get mmmDDHHMMA => DateFormat('MMM dd, hh:mm a').format(toLocal()); // Jan 01, 12:00 AM
  String get ddMMMhhmma => DateFormat('d MMM, hh:mm a').format(toLocal()); // 1 Jan, 12:00 AM
  String get yyyy => DateFormat.y().format(toLocal()); // 2022
  String get M => DateFormat.M().format(toLocal()); // 1
  String get mmm => DateFormat.MMMM().format(toLocal()); // January
  String get dMMMYYY => DateFormat('d MMM, yyyy').format(toLocal()); // 1 Jan, 2022
  String get yyyySlashMmmSlashDd => DateFormat('yyyy-MM-dd').format(toLocal()); // 2022-01-01
  String get ddMMyyyy => DateFormat('dd/MM/yyyy').format(toLocal()); // 01/01/2022
  String get earningDate => DateFormat('MMM dd, hh:mm a').format(toLocal()); // Jan 01, 12:00 AM
  String get ddMMyyyyhhmma => DateFormat('dd/MM/yyyy hh:mm a').format(toLocal()); // 01/01/2022 12:00 AM
  String get hhmmaDate => DateFormat('hh:mm a').format(toLocal()); // 12:00 AM
  String get mmmDD => DateFormat('MMM dd').format(toLocal()); // Jan 01
  String get ddMMMyyyy => DateFormat('dd MMM yyyy').format(toLocal()); // 01 Jan 2022
  String get hyphenyyyyMMDD => DateFormat('yyyy-MM-dd').format(toLocal()); //2024-12-28

  String format(String format) {
    return DateFormat(format).format(toLocal());
  }
}
