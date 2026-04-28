import 'package:flutter/material.dart';

import '../startup/presentation/pages/startup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static const String home = '/';
  static const String startup = '/startup';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startup:
        return MaterialPageRoute<void>(
          builder: (_) => const StartupPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const StartupPage(),
          settings: settings,
        );
    }
  }
}
