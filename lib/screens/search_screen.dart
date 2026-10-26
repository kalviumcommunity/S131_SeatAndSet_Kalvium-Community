import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/category_chip.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/screen_header.dart';
import '../widgets/furniture_card.dart';
import 'product_details_screen.dart';

/// Browse / Search — the combined experience opened by both Home's search
/// bar and the "Browse" bottom-nav tab (per the task: they're the same
/// screen, not two separate ones). Filters [DemoData.furniture] by a
/// free-text query and/or a category chip at once; see
/// [DemoData.filter].
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoData.filter(category: _selectedCategory, query: _query);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(title: 'Browse Furniture'),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Try "sofa", "bed", "table"...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      label: 'All',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    for (final category in DemoData.categories) ...[
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: category,
                        selected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No furniture found',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        itemCount: items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 13,
                              crossAxisSpacing: 13,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return FurnitureCard(
                            item: item,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(item: item),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.browse),
    );
  }
}
