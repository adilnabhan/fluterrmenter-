import 'package:mentor_mobile_app/imports_bindings.dart';

class AddMemberOrLeadSelectionSheet extends StatefulWidget {
  const AddMemberOrLeadSelectionSheet({this.onSortSelected, super.key, this.selectedSort});

  final ({String label, String value})? selectedSort;

  final void Function(String label, String value)? onSortSelected;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, backgroundColor: Colors.white, builder: (context) => this);
  }

  @override
  State<AddMemberOrLeadSelectionSheet> createState() => _AddMemberOrLeadSelectionSheetState();
}

class _AddMemberOrLeadSelectionSheetState extends State<AddMemberOrLeadSelectionSheet> with SingleTickerProviderStateMixin {
  ({String label, String value})? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedSort;
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
        Wrap(
          spacing: 8,
          children: [
            ...[(label: 'Member', value: 'member'), (label: 'Trainer', value: 'trainer')].map(_sortTile),
          ],
        ).pOnly(bottom: 32, top: 16),
        Button.filled(
          title: 'Continue',
          buttonColor: AppColors.primary,
          ontap: () {
            if (_selectedItem == null) {
              Dialogs.showSnack(msg: 'Please select a sort option');
              return;
            }
            context.pop();
            widget.onSortSelected?.call(_selectedItem!.label, _selectedItem!.value);
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
        setState(() {
          _selectedItem = item;
        });
      },
      label: Text(item.label.pascalCase),
      icon: const Icon(Icons.radio_button_off),
    );
  }
}
