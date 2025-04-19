import 'package:mentor_mobile_app/imports_bindings.dart';

class KRefreshIndicator extends StatelessWidget {
  const KRefreshIndicator({required this.child, required this.onRefresh, super.key});

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, backgroundColor: AppColors.light, color: AppColors.primary, child: child);
  }
}
