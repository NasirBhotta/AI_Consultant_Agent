import 'package:agent_app/src/app/app_gate.dart';
import 'package:agent_app/src/app/startup/presentation/pages/startup_error_page.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../app_startup.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final AppStartup _startup = AppStartup();

  bool _isInitializing = true;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _goNext() async {
    final nextScreen = await AppGate.resolve();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }

  Future<void> _loadApp() async {
    setState(() {
      _isInitializing = true;
      _startupError = null;
    });

    try {
      await _startup.initialize();
      await _goNext();
    } catch (e, st) {
      AppLogger.error('Startup failed', e, st);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => StartupErrorPage(message: e.toString(), onRetry: _loadApp),
        ),
      );
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
