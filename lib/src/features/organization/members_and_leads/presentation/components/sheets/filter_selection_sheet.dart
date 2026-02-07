import 'package:mentor_mobile_app/imports_bindings.dart';

class FilterSelectionSheet extends StatefulWidget {
  const FilterSelectionSheet({
    required this.items,
    this.onFilterSelected,
    super.key,
    this.selectedFilters,
  });

  final List<({String label, String value})>? selectedFilters;
  final List<({String label, String value})> items;
  final void Function(List<({String label, String value})>? values)?
  onFilterSelected;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => this,
    );
  }

  @override
  State<FilterSelectionSheet> createState() => _FilterSelectionSheetState();
}

class _FilterSelectionSheetState extends State<FilterSelectionSheet>
    with SingleTickerProviderStateMixin {
  List<({String label, String value})>? _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = [...?widget.selectedFilters];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Filter', style: AppStyles.text18Px.poppins.w700.dark),
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.close, color: AppColors.textGrey),
            ),
          ],
        ),
        const Divider(thickness: 1, color: Color(0xffDDDDDD)),
        Wrap(
          spacing: 8,
          children: [...widget.items.map(_sortTile)],
        ).pOnly(bottom: 32, top: 16),
        Button.filled(
          title: 'Show Result',
          buttonColor: AppColors.primary,
          ontap: () {
            if (_selectedItems == null) {
              Dialogs.showSnack(msg: 'Please select a filter option');
              return;
            }
            widget.onFilterSelected?.call(_selectedItems);
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
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xffFBEEEE),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.primary,
        ),
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
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xffDDDDDD)),
        shape: const StadiumBorder(),
        foregroundColor: const Color(0xff444444),
      ),
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
