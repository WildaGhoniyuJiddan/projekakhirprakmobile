import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/monex_theme.dart';

// 5.1. SURFACE CARD — kartu dasar dengan border halus

/// Kartu permukaan standar Monex: radius 20, border 1px `borderSubtle`,
/// fill `surface`. [onTap] membuat kartu bisa ditekan (ink ripple).
class MonexSurfaceCard extends StatelessWidget {
  const MonexSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(MonexSpacing.cardPadding),
    this.radius = MonexSpacing.radiusCard,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? palette.surface) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? palette.borderSubtle, width: 1),
      boxShadow: boxShadow ?? palette.cardShadow,
    );

    final content = Material(
      type: MaterialType.transparency,
      child: Padding(padding: padding, child: child),
    );
    final card = onTap == null
        ? DecoratedBox(decoration: decoration, child: content)
        : Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: decoration,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                child: content,
              ),
            ),
          );
    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

/// Kartu dengan gradien lime radial (kartu utama / hero).
class MonexGradientCard extends StatelessWidget {
  const MonexGradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MonexSpacing.cardPadding),
    this.radius = MonexSpacing.radiusCard,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  // Opsional: isi `color` untuk mengganti warna kartu gradien jadi warna solid.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final useDefaultGradient = color == null || color == MonexColors.lime;
    final content = Material(
      type: MaterialType.transparency,
      child: Padding(padding: padding, child: child),
    );
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: useDefaultGradient ? null : color,
          gradient: useDefaultGradient
              ? MonexDecorations.visaCardGradient
              : null,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: palette.heroShadow,
        ),
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

// 5.2. APP BAR — judul + tombol aksi lingkaran

/// App bar Monex: judul rata-kiri, aksi melingkar (surfaceElevated).
///
/// [leadingIcon]/[actions] opsional agar pemanggil bebas; [showBack] memakai
/// `Navigator.maybePop` sehingga tetap aman di layar yang bukan route pushed.
class MonexAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonexAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingTap,
    this.showBack = false,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final bool showBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: MonexSpacing.screenPaddingH,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (showBack || leadingIcon != null) ...[
            _CircleIconButton(
              icon: leadingIcon ?? Icons.arrow_back_ios_new_rounded,
              onTap: onLeadingTap ?? () => Navigator.of(context).maybePop(),
              size: 38,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        ...actions,
        const SizedBox(width: MonexSpacing.screenPaddingH),
      ],
    );
  }
}

/// Tombol aksi berbentuk lingkaran di app bar.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.tooltip,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = Material(
      color: background ?? theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.45,
            color: foreground ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tombol aksi lingkaran yang bisa dipakai di luar app bar.
class MonexCircleIconButton extends StatelessWidget {
  const MonexCircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.tooltip,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) => _CircleIconButton(
    icon: icon,
    onTap: onTap,
    size: size,
    tooltip: tooltip,
    background: background,
    foreground: foreground,
  );
}

// 5.3. TOMBOL

/// Tombol utama Monex: lime solid, teks gelap, glow neon.
class MonexPrimaryButton extends StatelessWidget {
  const MonexPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;
  // Opsional: ubah warna background/teks tombol utama per halaman.
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final bg = backgroundColor ?? palette.buttonBg;
    final fg = foregroundColor ?? palette.buttonFg;
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        disabledForegroundColor: fg.withValues(alpha: 0.6),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: loading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    if (!expanded) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MonexSpacing.radiusPill),
        boxShadow: onPressed != null && !loading ? palette.buttonShadow : null,
      ),
      child: button,
    );
  }
}

/// Tombol sekunder Monex: outline halus, tanpa glow.
class MonexSecondaryButton extends StatelessWidget {
  const MonexSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  // Opsional: ubah warna background/teks/border tombol sekunder per halaman.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? (palette.isDark ? null : palette.surface),
        foregroundColor: foregroundColor ?? palette.textPrimary,
        side: BorderSide(color: borderColor ?? palette.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: kMonexFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// 5.4. SEGMENTED CONTROL

/// Segmented control Monex (pill, satu segmen aktif).
class MonexSegmentedControl<T> extends StatelessWidget {
  const MonexSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<MonexSegment<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.isDark ? palette.surface : palette.surfaceHover,
        borderRadius: BorderRadius.circular(MonexSpacing.radiusMd),
        border: Border.all(color: palette.borderSubtle),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _SegmentButton(
                label: item.label,
                icon: item.icon,
                selected: item.value == value,
                onTap: () => onChanged(item.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// Satu segmen segmented control.
class MonexSegment<T> {
  const MonexSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? palette.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
          border: Border.all(
            color: selected ? palette.accentBorder : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? palette.accent : palette.textSecondary,
              ),
              if (label.isNotEmpty) const SizedBox(width: 6),
            ],
            if (label.isNotEmpty)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kMonexFontFamily,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? palette.accent : palette.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 5.5. PROGRESS

/// Progress bar Monex yang adaptif terhadap mode gelap dan terang.
class MonexProgressBar extends StatelessWidget {
  const MonexProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.trackColor,
    this.animate = true,
  });

  /// 0.0 – 1.0. Nilai di luar rentang dijepit (edge-case safe).
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final resolvedColor = color ?? palette.accent;
    final resolvedTrack = trackColor ?? palette.chartTrack;
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: clamped),
        duration: Duration(milliseconds: animate ? 600 : 0),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: resolvedTrack,
          valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
        ),
      ),
    );
  }
}

// 5.6. CHART — mini vertical bars

/// Bar chart vertikal mini (dipakai untuk tren & perbandingan).
class MonexMiniVerticalBars extends StatelessWidget {
  const MonexMiniVerticalBars({
    super.key,
    required this.values,
    this.height = 72,
    this.barColor,
    this.highlightIndex,
  });

  final List<double> values;
  final double height;
  final Color? barColor;

  /// Indeks bar yang disorot (mis. nilai tertinggi).
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final resolvedBar = barColor ?? palette.accent;
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Belum ada data',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    final maxV = values.reduce(math.max);
    final scale = maxV <= 0 ? 1.0 : maxV;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: values[i] / scale),
                  duration: Duration(milliseconds: 420 + i * 60),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Container(
                    height: height * (0.06 + 0.94 * v.clamp(0.0, 1.0)),
                    decoration: BoxDecoration(
                      color: i == highlightIndex
                          ? resolvedBar
                          : resolvedBar.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 5.7. TOAST

/// Toast kustom Monex (pengganti SnackBar berat).
///
/// Pakai [ScaffoldMessenger] agar aman dari context tanpa Scaffold —
/// memanggil `showMonexToast` dari luar Scaffold tidak akan crash.
void showMonexToast(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  final palette = MonexPalette.of(context);
  final color = isError
      ? palette.danger
      : isSuccess
      ? palette.buttonBg
      : palette.surfaceElevated;
  final fg = isError
      ? palette.onDanger
      : isSuccess
      ? palette.buttonFg
      : palette.textPrimary;

  messenger.showSnackBar(
    SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 18,
            color: fg,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: kMonexFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 5.9. LOADING — animasi memukau (shimmer, pulse, orbit)

/// Placeholder shimmer: kotak yang "menyala" berulang.
/// Dibuat stateless (tanpa `AnimationController`) supaya aman dipakai di
/// dalam `ListView.builder` tanpa menambah controller per item.
class MonexShimmer extends StatefulWidget {
  const MonexShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = MonexSpacing.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<MonexShimmer> createState() => _MonexShimmerState();
}

class _MonexShimmerState extends State<MonexShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final base = palette.surfaceElevated;
    final highlight = palette.isDark
        ? Color.lerp(base, MonexColors.lime, 0.18)!
        : Color.lerp(base, Colors.white, 0.72)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 - 2 * _c.value, 0),
                end: Alignment(1 - 2 * _c.value, 0),
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loader "orbit" — cincin lime berputar dengan inti berdenyut.
/// Dipakai sebagai loading state penuh layar yang tetap interaktif
/// (user bisa tetap scroll/keluar) dan bisa diberi [label].
class MonexOrbitLoader extends StatefulWidget {
  const MonexOrbitLoader({super.key, this.size = 64, this.label, this.message});

  final double size;
  final String? label;
  final String? message;

  @override
  State<MonexOrbitLoader> createState() => _MonexOrbitLoaderState();
}

class _MonexOrbitLoaderState extends State<MonexOrbitLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _spin,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _OrbitPainter(
                    color: palette.accent,
                    trackColor: palette.surfaceElevated,
                  ),
                ),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: widget.size * 0.32,
                  height: widget.size * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.buttonBg,
                    boxShadow: palette.buttonShadow,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 18),
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.message != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.message!,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.color, required this.trackColor});

  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final sweep = math.pi * 0.75;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) =>
      old.color != color || old.trackColor != trackColor;
}

// ============================================================================
// 5.9. FAB
// ============================================================================

/// FAB Monex: lingkaran lime dengan glow neon.
class MonexFab extends StatelessWidget {
  const MonexFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
    this.size = 56,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = MonexPalette.of(context);
    final fab = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: palette.buttonBg,
      foregroundColor: palette.buttonFg,
      elevation: 0,
      highlightElevation: 0,
      tooltip: tooltip,
      shape: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: palette.buttonShadow,
        ),
        child: Icon(icon, size: size * 0.5),
      ),
    );
    return fab;
  }
}

// ============================================================================
// 5.11. EMPTY STATE
// ============================================================================

/// Empty state: ikon, judul, pesan, dan aksi opsional.
class MonexEmptyState extends StatelessWidget {
  const MonexEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MonexSpacing.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: BorderRadius.circular(MonexSpacing.radiusCard),
              ),
              child: Icon(icon, size: 32, color: palette.accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              MonexPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
