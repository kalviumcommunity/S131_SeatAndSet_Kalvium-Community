/// Standard spacing values used for padding, margins, and gaps between
/// widgets.
///
/// Sticking to this fixed scale (instead of picking random numbers in each
/// screen) keeps the spacing rhythm consistent across the whole app.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  /// Left/right padding used on every screen edge in the reference designs
  /// (slightly wider than [md], matching the ~20px gutter seen in the PNGs).
  static const double screenPadding = 20;
}
