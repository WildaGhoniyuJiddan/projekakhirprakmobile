import 'package:flutter/material.dart';

import 'core/theme/monex_theme.dart';
import 'screens/root_screen.dart';
import 'state/app_scope.dart';
import 'state/theme_controller.dart';

/// Root widget WorthBang Lite.
class WorthBangApp extends StatelessWidget {
  const WorthBangApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      themeController: themeController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'WorthBang Lite',
            debugShowCheckedModeBanner: false,
            theme: MonexTheme.lightTheme,
            darkTheme: MonexTheme.darkTheme,
            themeMode: themeController.mode,
            locale: const Locale('id', 'ID'),
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
