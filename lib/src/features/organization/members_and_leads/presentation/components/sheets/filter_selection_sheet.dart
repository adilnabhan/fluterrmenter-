import 'package:mentor_mobile_app/imports_bindings.dart';

class FilterCategory {
  const FilterCategory({
    required this.title,
    required this.items,
    this.isSingleSelect = false,
  });

  final String title;
  final List<({String label, String value})> items;
  final bool isSingleSelect;
}

class FilterSelectionSheet extends StatefulWidget {
  const FilterSelectionSheet({
    this.items,
    this.categories,
    this.onFilterSelected,
    super.key,
    this.selectedFilters,
    this.title = 'Filter',
    this.isSingleSelect = false,
  });

  final String title;
  final bool isSingleSelect;
  final List<({String label, String value})>? selectedFilters;
  final List<({String label, String value})>? items;
  final List<FilterCategory>? categories;
  final void Function(List<({String label, String value})>? values)?
      onFilterSelected;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => this,
    );
  }

  @override
  State<FilterSelectionSheet> createState() => _FilterSelectionSheetState();
}

class _FilterSelectionSheetState extends State<FilterSelectionSheet> {
  late List<({String label, String value})> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = [...?widget.selectedFilters];
  }

  void _toggleItem(({String label, String value}) item, {bool isSingle = false, List<({String label, String value})>? categoryItems}) {
    setState(() {
      final isAlreadySelected = _selectedItems.any((e) => e.value == item.value);
      if (isAlreadySelected) {
        _selectedItems.removeWhere((e) => e.value == item.value);
      } else {
        if (isSingle) {
          if (categoryItems != null) {
            final categoryValues = categoryItems.map((e) => e.value).toSet();
            _selectedItems.removeWhere((e) => categoryValues.contains(e.value));
          } else {
            _selectedItems.clear();
          }
        }
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCategories = widget.categories != null && widget.categories!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: AppStyles.text18Px.poppins.w700.dark,
                    ),
                    const Spacer(),
                    if (_selectedItems.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedItems.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Reset',
                          style: AppStyles.text13Px.poppins.w500.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: context.pop,
                      icon: const Icon(Icons.close, color: AppColors.textGrey, size: 22),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xffEEEEEE)),
              
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: hasCategories
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.categories!.map((cat) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.title,
                                    style: AppStyles.text14Px.poppins.w600.copyWith(
                                      color: const Color(0xff333333),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: cat.items.map((item) {
                                      return _buildChip(
                                        item,
                                        isSingle: cat.isSingleSelect,
                                        categoryItems: cat.items,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: (widget.items ?? []).map((item) {
                            return _buildChip(
                              item,
                              isSingle: widget.isSingleSelect,
                            );
                          }).toList(),
                        ),
                ),
              ),

              // Bottom Apply Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Button.filled(
                  title: _selectedItems.isEmpty
                      ? 'Show Results'
                      : 'Apply (${_selectedItems.length})',
                  buttonColor: AppColors.primary,
                  raduis: 14,
                  size: const Size.fromHeight(50),
                  style: AppStyles.text15Px.poppins.w600.copyWith(color: Colors.white),
                  ontap: () {
                    widget.onFilterSelected?.call(_selectedItems);
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    ({String label, String value}) item, {
    bool isSingle = false,
    List<({String label, String value})>? categoryItems,
  }) {
    final isSelected = _selectedItems.any((e) => e.value == item.value);

    return InkWell(
      onTap: () => _toggleItem(item, isSingle: isSingle, categoryItems: categoryItems),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffFFF1F2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xffE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: AppStyles.text13Px.poppins.copyWith(
                color: isSelected ? AppColors.primary : const Color(0xff333333),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
