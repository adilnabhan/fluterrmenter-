import 'package:fluttertoast/fluttertoast.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

enum SnackType { success, error, warning }

@immutable
///
abstract class Dialogs {
  static String _sanitizeMessage(String? rawMsg) {
    if (rawMsg == null || rawMsg.trim().isEmpty) {
      return 'Something went wrong! Please try again later.';
    }
    String msg = rawMsg.trim();

    // Check for HTML error pages (e.g. Django debug 404/500, Cloudflare/Render HTML)
    final lower = msg.toLowerCase();
    if (lower.contains('<!doctype') ||
        lower.contains('<html') ||
        lower.contains('</html>') ||
        lower.contains('<body') ||
        lower.contains('<table') ||
        lower.contains('<style') ||
        lower.contains('<head')) {
      if (lower.contains('page not found') || lower.contains('404')) {
        return 'Requested resource not found.';
      }
      if (lower.contains('500') || lower.contains('internal server error')) {
        return 'Server error. Please try again later.';
      }
      if (lower.contains('502') || lower.contains('bad gateway')) {
        return 'Server is temporarily unavailable. Please try again.';
      }
      return 'An unexpected error occurred. Please try again.';
    }

    // Strip any residual HTML tags
    if (msg.contains('<') && msg.contains('>')) {
      msg =
          msg
              .replaceAll(RegExp(r'<[^>]*>'), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
    }

    // Strip technical exception prefixes
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring('Exception: '.length).trim();
    } else if (msg.startsWith('DioException')) {
      msg = 'Network or server error occurred. Please try again.';
    }

    // Cap message length so toasts never expand into giant full-screen cards
    if (msg.length > 120) {
      msg = '${msg.substring(0, 117)}...';
    }

    return msg.isEmpty ? 'Something went wrong! Please try again later.' : msg;
  }

  ///Show snackbar withoud context
  static Future<void> showSnack({
    String? msg,
    Widget? action,
    Duration? duration,
    SnackType type = SnackType.success,
    bool showIcon = false,
  }) async {
    final cleanMsg = _sanitizeMessage(msg);
    if (Platform.isAndroid || Platform.isIOS) {
      await Fluttertoast.cancel();
      await Fluttertoast.showToast(
        msg: cleanMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF4B5563),
        textColor: Colors.white,
        fontSize: 12,
        fontAsset: 'assets/fonts/Poppins-Regular.ttf',
      );
      return;
    }
    ScaffoldMessenger.of(Feggy.context!).showSnackBar(
      SnackBar(
        content:
            ClipRRect(
              borderRadius: BorderRadius.circular(10000),
              child: ColoredBox(
                color: AppColors.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        cleanMsg,
                        textAlign: TextAlign.center,
                        style: AppStyles.text14Px.w400.light,
                      ),
                    ),
                    if (showIcon)
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.light,
                        child: SvgPicture.asset(
                          'assets/images/icons/tick_icon.svg',
                        ),
                      ).pOnly(left: 8),
                  ],
                ).pxy(x: 16, y: 12),
              ),
            ).center,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        duration: duration ?? 1.seconds,
      ),
    );
  }

  ///Show session expired dialog
  static Future<void> showSessionExpiredDialog() async {
    await showDialog<void>(
      context: Feggy.context!,
      barrierDismissible: false,
      builder: (context) {
        return const SessionExpiredDialog();
      },
    );
  }

  /// Show enlarged circular profile photo dialog (Instagram style)
  static void showEnlargedProfilePhoto(
    BuildContext context,
    String? imageUrl, {
    String? name,
  }) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty || url == 'null') {
      unawaited(
        showSnack(
          msg:
              name != null && name.trim().isNotEmpty
                  ? 'No profile photo uploaded for ${name.trim()}'
                  : 'No profile photo uploaded',
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      barrierDismissible: true,
      builder: (ctx) {
        final diameter = (MediaQuery.of(ctx).size.width * 0.58).clamp(
          200.0,
          240.0,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            child: Center(
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    url,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
