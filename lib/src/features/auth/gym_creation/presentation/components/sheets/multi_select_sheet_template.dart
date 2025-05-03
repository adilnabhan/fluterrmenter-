import 'package:flutter/cupertino.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

class MultiSelectSheetTemplate extends StatelessWidget {
  const MultiSelectSheetTemplate({
    required this.titleText,
    required this.hintText,
    required this.emptyText,
    required this.errorText,
    required this.isLoading,
    required this.isSearching,
    required this.selectedValues,
    required this.availableValues,
    required this.onChangedField,
    required this.onRetry,
    required this.onSubmit,
    super.key,
  });

  final String titleText;
  final String hintText;
  final String emptyText;
  final String errorText;
  final bool isLoading;
  final bool isSearching;
  final ValueNotifier<List<({String value, String label})>> selectedValues;
  final List<({String value, String label})> availableValues;
  final void Function(String q) onChangedField;
  final void Function(List<({String value, String label})> values) onSubmit;
  final void Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          centerTitle: false,
          title: Text(titleText, style: AppStyles.text16Px.poppins.w700.dark),
          actions: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: SvgPicture.asset('assets/images/svg/icons/close_outlined.svg', height: 20, width: 20),
            ).pOnly(left: 16),
          ],
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (q) {
                EasyDebounce.debounce('search_query', const Duration(milliseconds: 100), () {
                  onChangedField(q);
                });
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                filled: false,
                prefixIcon: SizedBox.square(dimension: 32, child: SvgPicture.asset('assets/images/svg/icons/search.svg', height: 32, width: 32, color: AppColors.textGrey).center),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xffDDDDDD))),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: selectedValues,
              builder: (context, values, child) {
                if (values.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 33,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedValues.value.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xffF7F7F7), borderRadius: BorderRadius.circular(80000)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedValues.value[index].label, style: AppStyles.text14Px.poppins.w400.dark),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                selectedValues.value = selectedValues.value.where((element) => element.value != selectedValues.value[index].value).toList();
                              },
                              child: SvgPicture.asset('assets/images/svg/icons/close_outlined.svg', height: 16, width: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).pOnly(top: 20);
              },
            ),
            if (isSearching) const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.lightPrimary))),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (errorText.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(errorText, style: AppStyles.text14Px.poppins.w500.dark),
                          const SizedBox(height: 8),
                          SizedBox(width: 80, child: Button.filled(ontap: onRetry, title: 'Retry', raduis: 80000, buttonColor: AppColors.primary)),
                        ],
                      ),
                    );
                  }
                  if (isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (availableValues.isEmpty) {
                    return Center(child: Text(emptyText, style: AppStyles.text14Px.poppins.w500.dark));
                  }
                  return ListView.separated(
                    itemCount: availableValues.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 2);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (selectedValues.value.any((element) => element.value == availableValues[index].value)) {
                            selectedValues.value = selectedValues.value.where((element) => element.value != availableValues[index].value).toList();
                          } else {
                            selectedValues.value = [...selectedValues.value, availableValues[index]];
                          }
                        },
                        child: Text(availableValues[index].label, style: AppStyles.text14Px.poppins.w400.dark).pxy(x: 20, y: 20),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ).pad(16),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: selectedValues,
          builder: (context, values, child) {
            return Button.filled(
              title: 'Save',
              isDisabled: values.isEmpty,
              buttonColor: AppColors.primary,
              disabledButtonColor: const Color(0xffD0D0D0),
              ontap: () {
                if (values.isEmpty) {
                  Dialogs.showSnack(msg: 'Please select at least one.');
                  return;
                }
                context.pop();
                onSubmit(values);
              },
            ).pxy(x: 20, y: 30);
          },
        ),
      ),
    );
  }
}
