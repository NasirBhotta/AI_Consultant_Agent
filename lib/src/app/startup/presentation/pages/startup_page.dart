import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../app_startup.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final AppStartup _startup = AppStartup();

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    try {
      await _startup.initialize();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Startup failed. Continuing to the home screen.',
        error,
        stackTrace,
      );
    } finally {
      FlutterNativeSplash.remove();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1C33),
      body: const Center(
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF152742),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image(
                image: AssetImage('assets/branding/splash-icon.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
