/// Standard corner-radius values used for cards, buttons, inputs and chips.
///
/// The reference designs use two distinct "roundness" levels: a softer
/// radius for cards/images, and a fully-pill radius for buttons and inputs.
/// Reusing these constants (instead of picking a random number per widget)
/// keeps every rounded corner in the app consistent.
class AppRadius {
  AppRadius._();

  /// Cards, product images, promo banners (e.g. Home "Style Your Space").
  static const double card = 16;

  /// Text fields and outlined buttons (e.g. "Google" / "Phone OTP").
  static const double input = 16;

  /// Filter chips (e.g. "All", "2 Seater" on the Furniture List screen).
  static const double chip = 20;

  /// Primary buttons and the floating bottom navigation bar — the large,
  /// fully-rounded "pill" shape seen on "Sign In", "Add to Cart", etc.
  static const double pill = 28;
}
