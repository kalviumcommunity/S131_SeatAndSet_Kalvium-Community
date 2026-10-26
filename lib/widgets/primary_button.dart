import 'package:flutter/material.dart';

/// A themed button used anywhere we need a main call-to-action
/// (e.g. "Browse Furniture", "Rent Now").
///
/// It just wraps [ElevatedButton] so every screen gets the same look
/// (from `AppTheme.theme.elevatedButtonTheme`) without repeating style code.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// Text shown on the button.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
