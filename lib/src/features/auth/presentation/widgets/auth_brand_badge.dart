import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_extension.dart';

class AuthBrandBadge extends StatelessWidget {
  const AuthBrandBadge({
    super.key,
    this.size = 56,
    this.iconSize = 28,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: appTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: appTheme.borderStrong),
      ),
      child: Icon(
        Icons.keyboard_command_key_rounded,
        color: appTheme.successSoft,
        size: iconSize,
      ),
    );
  }
}
