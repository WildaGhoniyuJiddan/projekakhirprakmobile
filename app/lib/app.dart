import 'package:flutter/material.dart';

import 'core/theme/monex_theme.dart';
import 'screens/root_screen.dart';
import 'state/app_dependencies.dart';
import 'state/app_scope.dart';

/// Root widget WorthBang Lite.
class WorthBangApp extends StatelessWidget {
  const WorthBangApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: ListenableBuilder(
        listenable: dependencies.themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'WorthBang Lite',
            debugShowCheckedModeBanner: false,
            theme: MonexTheme.lightTheme,
            darkTheme: MonexTheme.darkTheme,
            themeMode: dependencies.themeController.mode,
            locale: const Locale('id', 'ID'),
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
