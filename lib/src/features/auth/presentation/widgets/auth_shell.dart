import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_extension.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child, this.maxWidth = 420});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.appBackground,
      // appBar: AppBar(backgroundColor: appTheme.appBackground),
      body: SafeArea(child: Center(child: SingleChildScrollView(child: child))),
    );
  }
}
