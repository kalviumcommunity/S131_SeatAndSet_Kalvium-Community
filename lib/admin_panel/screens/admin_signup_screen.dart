import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';
import '../widgets/admin_logo.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_button.dart';
import '../services/admin_auth_service.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AdminAuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _accessCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Passwords do not match'),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.registerAdmin(
      fullName: _fullNameController.text,
      workEmail: _emailController.text,
      accessCode: _accessCodeController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Admin account created successfully!'),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(error)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AdminColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Back Button & Mini Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF262854),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF383B74),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const AdminLogo(size: 30),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Screen Header
                      const Text(
                        'Create Admin Account',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage inventory, orders and deliveries.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Full Name
                      AdminTextField(
                        label: 'Full Name',
                        hintText: 'Your name',
                        controller: _fullNameController,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AdminColors.textSecondary,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Work Email
                      AdminTextField(
                        label: 'Work Email',
                        hintText: 'admin@seatandset.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: AdminColors.textSecondary,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your work email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Admin Access Code
                      AdminTextField(
                        label: 'Admin Access Code',
                        hintText: 'SNS-ADM-2025',
                        controller: _accessCodeController,
                        prefixIcon: const Icon(
                          Icons.vpn_key_outlined,
                          color: AdminColors.textSecondary,
                          size: 19,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the admin access code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      AdminTextField(
                        label: 'Password',
                        hintText: '••••••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AdminColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AdminColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      AdminTextField(
                        label: 'Confirm Password',
                        hintText: '••••••••••',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AdminColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AdminColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Security Note Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AdminColors.badgeBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AdminColors.badgeBorder,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF818CF8),
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Access code is shared by your organisation owner.',
                                style: TextStyle(
                                  color: AdminColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Account Button
                      AdminButton(
                        text: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _handleSignup,
                      ),
                      const SizedBox(height: 20),

                      // Already have an account? Login
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AdminColors.textMuted,
                                fontSize: 13.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
