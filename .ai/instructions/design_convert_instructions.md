# Design to Flutter Code Conversion Guide

## Project Structure

### Design Assets
- All UI design files should be placed in `assets/images/svg/vectors/design.svg`
- Reference implementation: [sent_otp_screen.dart](lib/src/features/auth/login/presentation/screens/sent_otp_screen.dart)

### Style Guidelines

1. **Colors**
- Use predefined colors from [AppColors](lib/core/themes/app_colors.dart)
- If new colors needed:
  ```dart
  static const Color newColor = Color(0xFFHEXCODE);
  ```

2. **Typography**
- Use predefined styles from [AppStyles](lib/core/themes/app_styles.dart)
- Example: `AppStyles.text14Px.poppins.w400`

3. **Theming**
- Follow [AppThemes](lib/core/themes/app_themes.dart) for consistent theming
- Use theme extensions for custom styles

### Extensions to Use

1. **Widget Extensions** ([widget_extension.dart](lib/core/extensions/widget_extension.dart))
```dart
// Padding
widget.pad(16)
widget.pxy(x: 16, y: 8)
widget.pOnly(left: 16)

// Alignment
widget.center
widget.align(Alignment.center)

// Visibility
widget.visible(isVisible: true)
```

2. **Typography Extensions** ([typography_extension.dart](lib/core/extensions/typography_extension.dart))
```dart
// Font weights
text.poppins.w400
text.poppins.w500
text.poppins.w600

// Colors
text.dark
text.light
text.primary
```

## Implementation Steps

1. **Screen Structure**
```dart
class ScreenName extends StatelessWidget {
  const ScreenName({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Implementation
    );
  }
}
```

2. **Responsive Design**
- Use `.w` for width measurements
- Use `.h` for height measurements
- Use `context.width` and `context.height` for screen dimensions

3. **Widget Hierarchy**
- Break down complex UIs into smaller widgets
- Keep widget methods private if used only within the screen

## Example Implementation

Reference the [sent_otp_screen.dart](lib/src/features/auth/login/presentation/screens/sent_otp_screen.dart) for:
- Screen structure
- Widget organization
- Styling implementation
- Extension usage

## Quality Checklist

- [ ] Use predefined colors and styles
- [ ] Implement responsive layouts
- [ ] Follow widget naming conventions
- [ ] Use provided extensions
- [ ] Maintain consistent padding/margin
- [ ] Break down complex widgets