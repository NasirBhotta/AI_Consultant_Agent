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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/branding/splash-logo.png',
                width: 300,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 2),
              Image.asset(
                'assets/branding/splash-branding.png',
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
