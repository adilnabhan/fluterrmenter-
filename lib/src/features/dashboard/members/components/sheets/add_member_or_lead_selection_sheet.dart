import 'package:mentor_mobile_app/imports_bindings.dart';

class AddMemberOrLeadSelectionSheet extends StatefulWidget {
  const AddMemberOrLeadSelectionSheet({super.key});

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(context: context, backgroundColor: Colors.white, builder: (context) => this);
  }

  @override
  State<AddMemberOrLeadSelectionSheet> createState() => _AddMemberOrLeadSelectionSheetState();
}

class _AddMemberOrLeadSelectionSheetState extends State<AddMemberOrLeadSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [Text('Add', style: AppStyles.text18Px.poppins.w700.dark), IconButton(onPressed: context.pop, icon: const Icon(Icons.close, color: AppColors.textGrey))]).pad(16),
      ],
    ).pad(16);
  }
}
