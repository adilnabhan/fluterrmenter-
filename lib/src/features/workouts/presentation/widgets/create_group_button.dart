import 'package:mentor_mobile_app/imports_bindings.dart';

class CreateGroupButton extends StatelessWidget {
  const CreateGroupButton({
    required this.onTap,
    this.onLongPress,
    this.label = 'Create new group',
    super.key,
  });
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD30000),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD30000).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
