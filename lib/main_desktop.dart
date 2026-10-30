import 'package:mentor_mobile_app/imports_bindings.dart';

/// Entrypoint for running the Desktop Fitness Center application.
/// 
/// Runs with:
/// ```powershell
/// flutter run -d windows -t lib/main_desktop.dart
/// ```
void main() {
  bootstrap(() => const DesktopAppView());
}
