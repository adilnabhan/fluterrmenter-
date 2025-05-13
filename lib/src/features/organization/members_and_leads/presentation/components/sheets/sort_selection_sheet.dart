import 'package:mentor_mobile_app/imports_bindings.dart';

class SortSelectionSheet extends StatefulWidget {
  const SortSelectionSheet({required this.items, this.onSortSelected, super.key, this.selectedSorts});

  final List<({String label, String value})>? selectedSorts;
  final List<({String label, String value})> items;
  final void Function(List<({String label, String value})>? values)? onSortSelected;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, backgroundColor: Colors.white, builder: (context) => this);
  }

  @override
  State<SortSelectionSheet> createState() => _SortSelectionSheetState();
}

class _SortSelectionSheetState extends State<SortSelectionSheet> with SingleTickerProviderStateMixin {
  List<({String label, String value})>? _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = [...?widget.selectedSorts];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Sort', style: AppStyles.text18Px.poppins.w700.dark), IconButton(onPressed: context.pop, icon: const Icon(Icons.close, color: AppColors.textGrey))],
        ),
        const Divider(thickness: 1, color: Color(0xffDDDDDD)),
        Wrap(spacing: 8, children: [...widget.items.map(_sortTile)]).pOnly(bottom: 32, top: 16),
        Button.filled(
          title: 'Show Result',
          buttonColor: AppColors.primary,
          ontap: () {
            if (_selectedItems == null) {
              Dialogs.showSnack(msg: 'Please select a sort option');
              return;
            }
            widget.onSortSelected?.call(_selectedItems);
            context.pop();
          },
        ).pOnly(bottom: 32),
      ],
    ).pad(16);
  }

  Widget _sortTile(({String label, String value}) item) {
    final isSelected = _selectedItems?.contains(item) ?? false;
    if (isSelected) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xffFBEEEE), shape: const StadiumBorder(), foregroundColor: AppColors.primary),
        onPressed: () {
          setState(() {
            _selectedItems = _selectedItems?.where((e) => e != item).toList();
          });
        },
        icon: Text(item.label),
        label: const Icon(Icons.check),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xffDDDDDD)), shape: const StadiumBorder(), foregroundColor: const Color(0xff444444)),
      onPressed: () {
        setState(() {
          _selectedItems = [...?_selectedItems, item];
        });
      },
      icon: Text(item.label.pascalCase),
      label: const Icon(Icons.add),
    );
  }
}
