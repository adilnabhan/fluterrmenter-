import 'package:mentor_mobile_app/imports_bindings.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({required this.sortLabel, super.key, this.isSelected = false, this.onTap});

  final bool isSelected;
  final void Function()? onTap;
  final String sortLabel;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xffFFF1F2) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide(color: isSelected ? const Color(0xffF8BDBE) : const Color(0xffDDDDDD)),
      ),
      onPressed: () {
        onTap?.call();
      },
      child: Text(sortLabel, style: AppStyles.text12Px.poppins.copyWith(color: isSelected ? const Color(0xffCF0B10) : const Color(0xff222222))),
    );
  }
}
