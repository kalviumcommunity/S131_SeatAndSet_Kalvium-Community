import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_logo_mark.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

/// Screen 4 — Sign Up (`design_reference/04_sign_up.png`).
///
/// --- Layout (for viva) ---
/// Reuses the same approach as [SignInScreen]: no custom field/button
/// styling — everything comes from `AppTheme.theme` (filled rounded text
/// fields with a green focus border, the pill `ElevatedButton` for
/// "Create Account", `OutlinedButton` for "Google"/"Phone OTP",
/// `CheckboxTheme`, `TextButtonTheme`/`AppTextStyles.link`). Spacing
/// between sections is fixed dp values measured directly off the
/// reference (same 472 x 1024 px phone-frame crop as the other
/// references, i.e. the same ~393 x 852 design canvas, so 1 reference
/// px ≈ 0.8326 dp).
///
/// Unlike Sign In, this screen has no hero illustration card — instead
/// there's a soft warm radial glow behind the small top-right logo,
/// reproduced the same way as the big logo's glow on [OnboardingPageOne]
/// (a `RadialGradient` fading the same warm color to transparent, not to
/// `Colors.transparent`, so it doesn't fade through muddy gray).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _agreedToTerms = true;
  bool _obscurePassword = true;

  Future<void> _goToHome() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password.'),
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy.'),
        ),
      );
      return;
    }

    final error = await UserSession.instance.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: AppSpacing.md),

              // Back button + small logo, on a soft warm glow — same
              // "RadialGradient fading the same color to zero alpha"
              // technique as OnboardingPageOne's big logo glow.
              SizedBox(
                width: double.infinity,
                height: 72,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -AppSpacing.screenPadding,
                      top: -28,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFE4D3B0).withValues(alpha: 0.45),
                              const Color(0xFFE4D3B0).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 0,
                      top: 6,
                      child: AppLogoMark(size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Create Account', style: AppTextStyles.heading),
              const SizedBox(height: 14),
              const Text(
                "Sign up to rent furniture you'll love.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 22),
              const Text('Full Name', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 11),
              const Text('Email', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 11),
              const Text('Phone Number', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(
                    Icons.phone_android_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 11),
              const Text('Password', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Create a password',
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

              const SizedBox(height: 15),
              InkWell(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) =>
                            setState(() => _agreedToTerms = value ?? false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Privacy Policy',
                              style: AppTextStyles.link,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              PrimaryButton(label: 'Create Account', onPressed: _goToHome),

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

              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: const _CircleGlyph(
                        letter: 'G',
                        color: Color(0xFF4285F4),
                      ),
                      label: 'Google',
                      onPressed: () => _showPlaceholder('Google sign up'),
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

              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log in',
                        style: AppTextStyles.link,
                        recognizer: (TapGestureRecognizer()
                          ..onTap = _goToSignIn),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two "Google" / "Phone OTP" outlined buttons — identical to
/// [SignInScreen]'s version.
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
/// glyphs, matching [SignInScreen].
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
