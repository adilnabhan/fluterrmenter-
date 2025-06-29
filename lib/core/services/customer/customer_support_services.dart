import 'package:mentor_mobile_app/imports_bindings.dart';

///
@immutable
final class CustomerSupportServices {
  ///
  static const String _phoneNumber = '918590811546';

  ///
  static final Uri _whatsappChat = Uri.parse('https://api.whatsapp.com/send?phone=$_phoneNumber&text=Hello,');

  ///
  static Future<void> whatsappChat() async {
    if (!await launchUrl(_whatsappChat)) {
      await Dialogs.showSnack(msg: "Can't chat now ! Please try again later");
    }
  }

  ///
  static Future<void> phoneCall() async {
    final launchUri = Uri(scheme: 'tel', path: _phoneNumber);
    if (!await launchUrl(launchUri)) {
      await Dialogs.showSnack(msg: "Can't call now ! Please try again later");
    }
  }
}
