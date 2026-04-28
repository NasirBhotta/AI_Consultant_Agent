import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.startup,
    );
  }
}
