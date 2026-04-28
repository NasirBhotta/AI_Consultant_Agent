import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../../core/utils/app_logger.dart';

class FirebaseBootstrap {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.info('Firebase already initialized.');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      AppLogger.info('Firebase initialized successfully.');
    } on UnsupportedError catch (error, stackTrace) {
      AppLogger.warning('Firebase is not configured for this platform.');
      AppLogger.error('Firebase initialization skipped.', error, stackTrace);
    } catch (error, stackTrace) {
      AppLogger.error('Firebase initialization failed.', error, stackTrace);
      rethrow;
    }
  }
}
