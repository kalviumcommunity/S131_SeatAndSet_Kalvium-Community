import 'package:flutter/material.dart';

import '../data/user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/screen_header.dart';
import '../widgets/primary_button.dart';

/// Edit Profile — pushed from Profile's "Edit Profile" row.
///
/// Edits are local frontend state only: saving writes straight into
/// [UserSession] (no backend to persist to), and Profile picks the
/// change up immediately via the session's `ValueNotifier`.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final UserProfile? profile = UserSession.instance.profile.value;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    UserSession.instance.updateProfile(
      name: _nameController.text.trim().isEmpty
          ? 'Guest User'
          : _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(title: 'Edit Profile'),
              const SizedBox(height: 24),
              const Text('Full Name', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              const Text('Email', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              const Text('Phone Number', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
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
              const SizedBox(height: 28),
              PrimaryButton(label: 'Save Changes', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
