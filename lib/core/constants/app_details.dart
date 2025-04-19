import 'package:mentor_mobile_app/imports_bindings.dart';

String appVersion = '';
String buildNumber = '';
const String whichEnv = String.fromEnvironment('whichEnv', defaultValue: 'Prod');

Future<void> getAppInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  appVersion = packageInfo.version;
  buildNumber = whichEnv == 'DEV' ? packageInfo.buildNumber : '';

  write('build number :$buildNumber');
}
