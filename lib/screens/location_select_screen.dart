import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/screen_header.dart';

/// Delivery-location picker, pushed from Home's "Deliver to" row.
///
/// Returns the chosen location string via `Navigator.pop`, which Home
/// awaits and stores in its own state — there's no persistence (no
/// backend yet), so the choice resets on app restart.
class LocationSelectScreen extends StatelessWidget {
  const LocationSelectScreen({super.key, required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                12,
                AppSpacing.screenPadding,
                0,
              ),
              child: const ScreenHeader(title: 'Select Location'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: DemoData.locations.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final String location = DemoData.locations[index];
                  final bool selected = location == currentLocation;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      location,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.primaryDark)
                        : null,
                    onTap: () => Navigator.of(context).pop(location),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
