import 'package:mentor_mobile_app/imports_bindings.dart';

class GymDetailsUpdateTemplateScreen extends StatefulWidget {
  const GymDetailsUpdateTemplateScreen({
    required this.title,
    required this.questionText,
    required this.label,
    required this.onSave,
    required this.initialValue,
    required this.validator,
    required this.hintText,
    required this.keyboardType,
    required this.inputFormatters,
    super.key,
  });

  final String title;
  final String questionText;
  final String label;
  final String hintText;
  final void Function(String value) onSave;
  final String initialValue;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<GymDetailsUpdateTemplateScreen> createState() => _GymDetailsUpdateTempleteScreenState();
}

class _GymDetailsUpdateTempleteScreenState extends State<GymDetailsUpdateTemplateScreen> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const PopButton().center, title: Text(widget.title, style: AppStyles.text16Px.poppins.w500)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.questionText, style: AppStyles.text16Px.poppins.w700.dark),
              const SizedBox(height: 16),
              Field(
                data: FieldData<String>(
                  type: FieldType.word,
                  textInputAction: TextInputAction.next,
                  label: widget.label,
                  requiredLabel: true,
                  validator: widget.validator,
                  onSubmitted: (value) {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(_controller.text);
                      context.pop();
                    }
                  },
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                    filled: false,
                    border: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                    errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.error)),
                    focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.borderGrey)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Button.filled(
        raduis: 12,
        title: 'Save',
        buttonColor: AppColors.primary,
        ontap: () {
          if (_formKey.currentState!.validate()) {
            widget.onSave(_controller.text);
            context.pop();
          }
        },
      ).pad(16).pxy(y: 16),
    );
  }
}
