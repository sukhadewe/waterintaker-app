import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'services/ads.dart';
import 'services/notifications.dart';
import 'services/purchases.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const WaddleApp());
  // background init, never block the first frame
  Reminders.init().then((_) => Reminders.reschedule()).catchError((_) {});
  Purchases.init();
  Ads.init();
}

class WaddleApp extends StatelessWidget {
  const WaddleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => MaterialApp(
        title: 'Waddle',
        debugShowCheckedModeBanner: false,
        navigatorKey: AppNavigator.key,
        theme: buildTheme(),
        home: AppState.instance.onboarded ? const HomeScreen() : const OnboardingFlow(),
      ),
    );
  }
}
