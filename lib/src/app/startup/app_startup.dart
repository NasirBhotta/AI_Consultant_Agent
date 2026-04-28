import '../../core/utils/app_logger.dart';
import '../../services/firebase/firebase_bootstrap.dart';

class AppStartup {
  Future<void> initialize() async {
    AppLogger.info('App startup began.');

    await FirebaseBootstrap.initialize();
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    AppLogger.info('App startup completed.');
  }
}
