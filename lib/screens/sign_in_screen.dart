import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

/// Screen 3 — Sign In (`design_reference/03_sign_in.png`).
///
/// --- Hero artwork (for viva) ---
/// Like the onboarding illustrations, the sage-green hero card (logo,
/// "Seat and Set" wordmark, sofa illustration, decorative circles) is the
/// actual reference artwork — cropped out of `03_sign_in.png` with Pillow
/// and saved as `assets/images/sign_in_hero.png` — rather than redrawn
/// with Flutter shapes, so it's pixel-identical to the reference instead
/// of an approximation.
///
/// --- Everything else ---
/// The form below the hero card deliberately reuses the app's existing
/// theme (see `AppTheme.theme` in `lib/theme/app_theme.dart`) instead of
/// styling each field/button from scratch: `InputDecorationTheme` already
/// gives text fields the reference's filled-white-rounded-box look with a
/// green focus border, `ElevatedButtonTheme` already gives "Sign In" the
/// full pill shape, `OutlinedButtonTheme` already gives "Google"/"Phone
/// OTP" their rounded-box outline, and `CheckboxTheme`/`TextButtonTheme`
/// already match "Remember me" and "Forgot Password?"/"Sign up". Spacing
/// values between sections are fixed dp numbers measured directly off the
/// reference (its phone frame crops to 472 x 1025 px, matching a 393 x
/// 852 design canvas almost exactly — so 1 reference px ≈ 0.8326 dp) —
/// not screen-width fractions like the onboarding pages, since a form's
/// text/field sizes shouldn't grow with screen width the way a full-bleed
/// illustration should.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const String _heroAsset = 'assets/images/sign_in_hero.png';
  static const double _heroAspect = 423 / 232;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToHome() {
    UserSession.instance.signIn(_emailController.text);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _goToSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  /// Placeholder for actions with no real backend yet (Google, Phone OTP,
  /// Forgot Password) — just confirms the tap registered.
  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double heroWidth = sw - AppSpacing.screenPadding * 2;
    final double heroHeight = heroWidth / _heroAspect;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Hero card — real reference artwork (see class doc above).
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.asset(
                  _heroAsset,
                  width: heroWidth,
                  height: heroHeight,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),

              const SizedBox(height: 22),
              const Text('Welcome Back', style: AppTextStyles.heading),
              const SizedBox(height: 14),
              const Text(
                'Sign in to continue renting your favourites.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),
              const Text('Email or Phone', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 9),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Enter your email or phone',
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Text('Password', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 9),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showPlaceholder('Forgot Password'),
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              PrimaryButton(label: 'Sign In', onPressed: _goToHome),

              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      'or continue with',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: const _CircleGlyph(
                        letter: 'G',
                        color: Color(0xFF4285F4),
                      ),
                      label: 'Google',
                      onPressed: () => _showPlaceholder('Google sign in'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SocialButton(
                      icon: const _CircleGlyph(
                        letter: '#',
                        color: AppColors.primaryDark,
                      ),
                      label: 'Phone OTP',
                      onPressed: () => _showPlaceholder('Phone OTP'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign up',
                        style: AppTextStyles.link,
                        recognizer: (TapGestureRecognizer()
                          ..onTap = _goToSignUp),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two "Google" / "Phone OTP" outlined buttons.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}

/// A small circle outline with a single colored letter/symbol inside —
/// used for the simplified, single-color "G" (Google) and "#" (Phone OTP)
/// glyphs the reference uses in place of real brand logos.
class _CircleGlyph extends StatelessWidget {
  const _CircleGlyph({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
