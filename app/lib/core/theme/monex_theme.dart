import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design system "Monex" — Deep Dark Fintech.
///
/// Plus Jakarta Sans di-*self-host* (bundled di `assets/fonts/`) supaya tema
/// konsisten tanpa fetch runtime. Mode terang memakai inversi semantik dari
/// token yang sama dengan aksen lime tetap konsisten di kedua mode.
abstract final class MonexColors {
  // Backgrounds
  static const Color canvas = Color(0xFF070A10);
  static const Color appBg = Color(0xFF0C0F17);

  // Surfaces & Borders
  static const Color surface = Color(0xFF1B202C);
  static const Color surfaceHover = Color(0xFF232938);
  static const Color surfaceElevated = Color(0xFF262C3C);
  static const Color borderSubtle = Color.fromRGBO(255, 255, 255, 0.06);
  static const Color borderLight = Color.fromRGBO(255, 255, 255, 0.10);

  // Primary Brand Accent (Neon Lime)
  static const Color lime = Color(0xFFACEF34);
  static const Color limeBright = Color(0xFFB8FF3B);
  static const Color limeMuted = Color.fromRGBO(172, 239, 52, 0.14);

  // Semantic & Secondary Accents
  static const Color danger = Color(0xFFF43F5E);
  static const Color dangerMuted = Color.fromRGBO(244, 63, 94, 0.15);
  static const Color chartPurple = Color(0xFFA855F7);
  static const Color chartSky = Color(0xFF38BDF8);
  static const Color chartTrack = Color(0xFF1E293B);
  static const Color barInactive = Color(0xFF475569);
  static const Color barActive = Color(0xFF64748B);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF020617);

  /// Warna verdict — semantik app (hijau/amber/merah) digeser ke palet
  /// dark agar kontras di atas [surface] tetap terbaca.
  /// Warna TIDAK pernah berdiri sendiri: selalu berpasangan dengan label teks.
  static const Color verdictGood = Color(0xFF4ADE80);
  static const Color verdictFair = Color(0xFFFBBF24);
  static const Color verdictBad = Color(0xFFF87171);
}

/// Token spacing & radius.
abstract final class MonexSpacing {
  static const double screenPaddingH = 20.0;
  static const double screenPaddingV = 16.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 14.0;
  static const double gridGap = 12.0;
  static const double sectionGap = 18.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusCard = 20.0;
  static const double radiusSheet = 24.0;
  static const double radiusPill = 999.0;
}

/// Dekorasi: gradient, glow, dan standard surface card.
abstract final class MonexDecorations {
  /// Radial Gradient Kartu Utama (circle at 18% 20%).
  static const RadialGradient visaCardGradient = RadialGradient(
    center: Alignment(-0.64, -0.60),
    radius: 1.4,
    colors: [
      Color(0xFFF7FAE9), // 0%
      Color(0xFFDEF98E), // 45%
      Color(0xFF97F129), // 100%
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Glow Hijau Neon untuk Tombol Utama & FAB.
  static List<BoxShadow> get limeGlowShadow => const [
    BoxShadow(
      color: Color.fromRGBO(172, 239, 52, 0.45),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  /// Soft Shadow untuk Kartu Highlight.
  static List<BoxShadow> get cardSoftShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.50),
      blurRadius: 30,
      spreadRadius: -10,
      offset: Offset(0, 10),
    ),
  ];

  /// Dekorasi Standar Surface Card.
  static BoxDecoration surfaceCard({
    double radius = MonexSpacing.radiusCard,
    Color? color,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? MonexColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? MonexColors.borderSubtle,
        width: 1,
      ),
    );
  }

  /// Dekorasi Kartu Gradien Neon.
  static BoxDecoration visaCard({double radius = MonexSpacing.radiusCard}) {
    return BoxDecoration(
      gradient: visaCardGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardSoftShadow,
    );
  }
}

/// Font family yang di-*self-host* (lihat `pubspec.yaml` → flutter.fonts).
const String kMonexFontFamily = 'PlusJakartaSans';

/// Palet warna per-mode (gelap dan terang).
@immutable
class MonexPalette {
  const MonexPalette({
    required this.brightness,
    required this.appBg,
    required this.canvas,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceElevated,
    required this.borderSubtle,
    required this.borderLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentBorder,
    required this.buttonBg,
    required this.buttonFg,
    required this.danger,
    required this.dangerMuted,
    required this.onDanger,
    required this.chartTrack,
    required this.barInactive,
    required this.barActive,
    required this.cardShadow,
    required this.heroShadow,
    required this.buttonShadow,
  });

  final Brightness brightness;
  final Color appBg;
  final Color canvas;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceElevated;
  final Color borderSubtle;
  final Color borderLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color accentBorder;
  final Color buttonBg;
  final Color buttonFg;
  final Color danger;
  final Color dangerMuted;
  final Color onDanger;
  final Color chartTrack;
  final Color barInactive;
  final Color barActive;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> heroShadow;
  final List<BoxShadow> buttonShadow;

  bool get isDark => brightness == Brightness.dark;

  static MonexPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// Menyesuaikan warna verdict agar tetap kontras di latar terang maupun gelap.
  Color readableVerdict(Color color) {
    if (isDark) return color;
    if (color == MonexColors.verdictGood) return const Color(0xFF15803D);
    if (color == MonexColors.verdictFair) return const Color(0xFFB45309);
    if (color == MonexColors.verdictBad) return const Color(0xFFDC2626);
    if (color == MonexColors.textSecondary) return textSecondary;
    return Color.lerp(color, Colors.black, 0.30)!;
  }

  static const MonexPalette dark = MonexPalette(
    brightness: Brightness.dark,
    appBg: MonexColors.appBg,
    canvas: MonexColors.canvas,
    surface: MonexColors.surface,
    surfaceHover: MonexColors.surfaceHover,
    surfaceElevated: MonexColors.surfaceElevated,
    borderSubtle: MonexColors.borderSubtle,
    borderLight: MonexColors.borderLight,
    textPrimary: MonexColors.textPrimary,
    textSecondary: MonexColors.textSecondary,
    textMuted: MonexColors.textMuted,
    accent: MonexColors.lime,
    accentSoft: MonexColors.limeMuted,
    accentBorder: Color.fromRGBO(172, 239, 52, 0.45),
    buttonBg: MonexColors.lime,
    buttonFg: MonexColors.textDark,
    danger: MonexColors.danger,
    dangerMuted: MonexColors.dangerMuted,
    onDanger: MonexColors.textDark,
    chartTrack: MonexColors.chartTrack,
    barInactive: MonexColors.barInactive,
    barActive: MonexColors.barActive,
    cardShadow: [],
    heroShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.50),
        blurRadius: 30,
        spreadRadius: -10,
        offset: Offset(0, 10),
      ),
    ],
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(172, 239, 52, 0.45),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const MonexPalette light = MonexPalette(
    brightness: Brightness.light,
    appBg: Color(0xFFF3F6FA),
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceHover: Color(0xFFF1F5F9),
    surfaceElevated: Color(0xFFE9EEF5),
    borderSubtle: Color(0xFFE2E8F0),
    borderLight: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    accent: Color(0xFF4D7C0F),
    accentSoft: Color(0xFFECFCCB),
    accentBorder: Color(0xFF84CC16),
    buttonBg: Color(0xFFA3E635),
    buttonFg: Color(0xFF0F172A),
    danger: Color(0xFFDC2626),
    dangerMuted: Color(0xFFFEE2E2),
    onDanger: Color(0xFFFFFFFF),
    chartTrack: Color(0xFFE2E8F0),
    barInactive: Color(0xFFCBD5E1),
    barActive: Color(0xFF64748B),
    cardShadow: [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, 0.05),
        blurRadius: 14,
        spreadRadius: -2,
        offset: Offset(0, 4),
      ),
    ],
    heroShadow: [
      BoxShadow(
        color: Color.fromRGBO(101, 163, 13, 0.22),
        blurRadius: 20,
        spreadRadius: -6,
        offset: Offset(0, 8),
      ),
    ],
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(101, 163, 13, 0.28),
        blurRadius: 16,
        spreadRadius: -4,
        offset: Offset(0, 6),
      ),
    ],
  );
}

/// Theme aplikasi untuk mode gelap dan terang.
abstract final class MonexTheme {
  static ThemeData get darkTheme => _build(MonexPalette.dark);

  static ThemeData get lightTheme => _build(MonexPalette.light);

  static ThemeData _build(MonexPalette p) {
    final base = ThemeData(brightness: p.brightness, useMaterial3: true);
    final baseTextTheme = base.textTheme.apply(
      fontFamily: kMonexFontFamily,
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );
    final dialogBg = p.isDark ? p.surfaceElevated : p.surface;

    return base.copyWith(
      scaffoldBackgroundColor: p.appBg,
      canvasColor: p.canvas,
      primaryColor: p.accent,
      dividerColor: p.borderSubtle,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.accent,
        onPrimary: p.isDark ? MonexColors.textDark : Colors.white,
        primaryContainer: p.surfaceElevated,
        onPrimaryContainer: p.textPrimary,
        secondary: p.buttonBg,
        onSecondary: p.buttonFg,
        secondaryContainer: p.accentSoft,
        onSecondaryContainer: p.textPrimary,
        surface: p.surface,
        onSurface: p.textPrimary,
        surfaceContainerHighest: p.surfaceElevated,
        onSurfaceVariant: p.textSecondary,
        surfaceContainerLow: p.surfaceHover,
        surfaceContainer: p.surface,
        surfaceContainerHigh: p.surfaceElevated,
        error: p.danger,
        onError: p.onDanger,
        errorContainer: p.dangerMuted,
        onErrorContainer: p.textPrimary,
        outline: p.borderLight,
        outlineVariant: p.borderSubtle,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: p.surface,
        onInverseSurface: p.textPrimary,
        inversePrimary: p.accent,
      ),
      textTheme: baseTextTheme.copyWith(
        // Angka nominal besar & display.
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: p.textPrimary,
        ),
        // Judul halaman utama.
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: p.textPrimary,
        ),
        // Nominal kartu sekunder.
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
        // Judul seksi & nama item list.
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        // Teks isi & menu.
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: p.textMuted,
        ),
        // Label kecil, timestamp, caption.
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.appBg,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: p.isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: p.surface,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: p.surface,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        titleTextStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: p.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.accent,
        unselectedItemColor: p.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentSoft,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? p.accent : p.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? p.textPrimary : p.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        hintStyle: TextStyle(color: p.textMuted, fontSize: 12),
        labelStyle: TextStyle(color: p.textSecondary, fontSize: 12),
        floatingLabelStyle: TextStyle(color: p.accent, fontSize: 12),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
          borderSide: BorderSide(color: p.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
          borderSide: BorderSide(color: p.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
          borderSide: BorderSide(color: p.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
          borderSide: BorderSide(color: p.danger, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.buttonBg,
          foregroundColor: p.buttonFg,
          disabledBackgroundColor: p.surfaceElevated,
          disabledForegroundColor: p.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.surfaceElevated,
          foregroundColor: p.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.textSecondary,
          selectedBackgroundColor: p.surfaceElevated,
          selectedForegroundColor: p.textPrimary,
          side: BorderSide(color: p.borderSubtle),
          textStyle: const TextStyle(
            fontFamily: kMonexFontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.accentSoft,
        side: BorderSide(color: p.borderSubtle),
        checkmarkColor: p.accent,
        labelStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 12,
          color: p.textSecondary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: p.accent,
        ),
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MonexSpacing.radiusSheet),
          side: BorderSide(color: p.borderSubtle),
        ),
        titleTextStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 13,
          color: p.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceElevated,
        contentTextStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MonexSpacing.radiusMd),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? p.buttonFg
              : p.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? p.buttonBg
              : p.surfaceElevated;
        }),
        trackOutlineColor: WidgetStatePropertyAll(p.borderLight),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.chartTrack,
        thumbColor: p.accent,
        overlayColor: p.accentSoft,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.chartTrack,
        circularTrackColor: p.chartTrack,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
          border: Border.all(color: p.borderSubtle),
        ),
        textStyle: TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 11,
          color: p.textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
