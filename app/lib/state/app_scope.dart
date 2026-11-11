import 'package:flutter/widgets.dart';

import 'theme_controller.dart';

/// Dependency container sederhana untuk widget tree.
///
/// Pada fase berikutnya, service/repository lain ditambahkan di sini.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.themeController,
    required super.child,
  });

  final ThemeController themeController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.themeController != themeController;
}
