import 'package:agent_app/src/app/providers/app_providers.dart';
import 'package:agent_app/src/app/startup/presentation/pages/startup_error_page.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupPage extends ConsumerStatefulWidget {
  const StartupPage({super.key});

  @override
  ConsumerState<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends ConsumerState<StartupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadApp();
    });
  }

  void _replaceScreen(Widget screen) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
    });
  }

  Future<void> _goNext() async {
    final nextScreen = await ref.read(appGateProvider.future);

    if (!mounted) {
      return;
    }

    _replaceScreen(nextScreen);
  }

  Future<void> _loadApp() async {
    try {
      ref.invalidate(appStartupProvider);
      ref.invalidate(appGateProvider);
      await ref.read(appStartupProvider.future);
      await _goNext();
    } catch (e, st) {
      AppLogger.error('Startup failed', e, st);

      if (!mounted) {
        return;
      }

      _replaceScreen(
        StartupErrorPage(message: e.toString(), onRetry: _loadApp),
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
