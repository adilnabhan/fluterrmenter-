import 'package:mentor_mobile_app/imports_bindings.dart';

class AddServicesSheet extends StatefulWidget {
  const AddServicesSheet({required this.selectedValues, required this.onSubmit, super.key});

  final List<({String value, String label})> selectedValues;
  final void Function(List<({String value, String label})> values) onSubmit;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, builder: (context) => this);
  }

  @override
  State<AddServicesSheet> createState() => _AddServicesSheetState();
}

class _AddServicesSheetState extends State<AddServicesSheet> {
  bool isLoading = true;
  bool isSearching = false;
  String errorText = '';
  late final ValueNotifier<List<({String value, String label})>> _selectedValues;

  @override
  void initState() {
    fetch(isLoading: true);
    super.initState();
    _selectedValues = ValueNotifier([...widget.selectedValues]);
  }

  Future<void> fetch({bool isLoading = false, bool isSearching = false, String? q}) async {
    setState(() {
      errorText = '';
      this.isLoading = isLoading;
      this.isSearching = isSearching;
    });
    final response = await CommonRepository().getAmenities(params: {if (q != null) 'name': q});
    response.fold((l) {
      if (isSearching) {
        errorText = l.msg;
      }
    }, (r) {});
    setState(() {
      this.isLoading = false;
      this.isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiSelectSheetTemplate(
      titleText: 'Add services',
      hintText: 'Search for services',
      emptyText: "Couldn't find services!",
      errorText: errorText,
      selectedValues: _selectedValues,
      availableValues: const [
        (value: '1', label: 'Personal Trainer'),
        (value: '2', label: 'Yoga'),
        (value: '3', label: 'Zumba'),
        (value: '4', label: 'Pilates'),
        (value: '5', label: 'Nutritionist'),
        (value: '6', label: 'Massage Therapist'),
      ],
      onChangedField: (q) {
        // Implement search functionality here
        fetch(isSearching: true, q: q);
      },
      isLoading: isSearching,
      isSearching: isLoading,
      onSubmit: widget.onSubmit,
      onRetry: () {
        fetch(isLoading: true);
      },
    );
  }
}
