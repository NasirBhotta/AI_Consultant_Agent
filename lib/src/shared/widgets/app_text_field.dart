import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.label,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hintText;
  final String? label;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
