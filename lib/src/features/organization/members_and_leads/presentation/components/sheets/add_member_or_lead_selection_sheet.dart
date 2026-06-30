import 'package:mentor_mobile_app/imports_bindings.dart';

class AddMemberOrLeadSelectionSheet extends StatefulWidget {
  const AddMemberOrLeadSelectionSheet({this.onSortSelected, super.key});

  final void Function(String label, String value)? onSortSelected;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, backgroundColor: Colors.white, builder: (context) => this);
  }

  @override
  State<AddMemberOrLeadSelectionSheet> createState() => _AddMemberOrLeadSelectionSheetState();
}

class _AddMemberOrLeadSelectionSheetState extends State<AddMemberOrLeadSelectionSheet> with SingleTickerProviderStateMixin {
  late ({String label, String value}) _selectedItem;
  final List<({String label, String value})> _sortOptions = [(label: 'Member', value: 'member'), (label: 'Trainer', value: 'trainer')];

  @override
  void initState() {
    super.initState();
    _selectedItem = _sortOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Add', style: AppStyles.text18Px.poppins.w700.dark), IconButton(onPressed: context.pop, icon: const Icon(Icons.close, color: AppColors.textGrey))],
        ),
        const Divider(thickness: 1, color: Color(0xffDDDDDD)),
        Wrap(spacing: 8, children: [..._sortOptions.map(_sortTile)]).pOnly(bottom: 32, top: 16),
        Button.filled(
          title: 'Continue',
          buttonColor: AppColors.primary,
          ontap: () {
            context.pop();
            widget.onSortSelected?.call(_selectedItem.label, _selectedItem.value);
          },
        ).pOnly(bottom: 32),
      ],
    ).pad(16);
  }

  Widget _sortTile(({String label, String value}) item) {
    final isSelected = _selectedItem == item;
    if (isSelected) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xffFBEEEE), shape: const StadiumBorder(), foregroundColor: AppColors.primary),
        onPressed: () {},
        label: Text(item.label),
        icon: const Icon(Icons.radio_button_checked),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xffDDDDDD)), shape: const StadiumBorder(), foregroundColor: const Color(0xff444444)),
      onPressed: () {
        if (!mounted) return;
        setState(() {
          _selectedItem = item;
        });
      },
      label: Text(item.label.pascalCase),
      icon: const Icon(Icons.radio_button_off),
    );
  }
}
