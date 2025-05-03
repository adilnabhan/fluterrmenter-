import 'package:mentor_mobile_app/imports_bindings.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({required this.selectedValues, required this.onSubmit, super.key});

  final List<({String value, String label})> selectedValues;
  final void Function(List<({String value, String label})> values) onSubmit;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, builder: (context) => this);
  }

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  bool isLoading = true;
  String errorText = '';
  late final ValueNotifier<List<({String value, String label})>> _selectedValues;
  final _filteredValues = <({String value, String label})>[];
  final _allValues = <({String value, String label})>[];

  @override
  void initState() {
    fetch(isLoading: true);
    super.initState();
    _selectedValues = ValueNotifier([...widget.selectedValues]);
  }

  Future<void> fetch({bool isLoading = false, String? q}) async {
    setState(() {
      errorText = '';
      this.isLoading = isLoading;
    });
    final response = await CommonRepository().getCategories(params: {if (q != null) 'name': q});
    response.fold(
      (l) {
        errorText = l.msg;
      },
      (r) {
        _allValues
          ..clear()
          ..addAll(r.results?.map((e) => (value: e.id.toString(), label: e.name ?? '')) ?? []);
        _filteredValues
          ..clear()
          ..addAll(_allValues);
      },
    );
    setState(() {
      this.isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiSelectSheetTemplate(
      titleText: 'Add categories',
      hintText: 'Search for categories',
      emptyText: 'No matching category found. Try a different search.',
      errorText: errorText,
      selectedValues: _selectedValues,
      availableValues: _filteredValues,
      onChangedField: (q) {
        if (q.isEmpty) {
          _filteredValues
            ..clear()
            ..addAll(_allValues);
        } else {
          _filteredValues
            ..clear()
            ..addAll(_allValues.where((e) => e.label.toLowerCase().contains(q.toLowerCase())));
        }
      },
      isLoading: isLoading,
      onSubmit: widget.onSubmit,
      onRetry: () {
        fetch(isLoading: true);
      },
    );
  }
}
