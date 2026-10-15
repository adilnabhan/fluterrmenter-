import 'package:flutter/material.dart';
import 'package:mentor_mobile_app/core/themes/app_colors.dart';

/// A reusable search bar widget with consistent styling across the app.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    super.key,
  });

  /// Placeholder text displayed when the field is empty.
  final String hintText;

  /// Optional controller for the text field.
  final TextEditingController? controller;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses Enter/Search).
  final ValueChanged<String>? onSubmitted;

  /// Optional suffix icon widget (e.g. clear button).
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
