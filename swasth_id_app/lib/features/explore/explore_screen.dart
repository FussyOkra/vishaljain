import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/explore/disease_category_screen.dart';
import 'package:swasth_id_app/features/swasth_ai/swasth_ai_screen.dart';
import 'package:swasth_id_app/widgets/gradient_scaffold.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Viral Diseases', 'icon': Icons.bug_report, 'color': Color(0xFFEF5350)},
    {'name': 'Bacterial Diseases', 'icon': Icons.local_hospital, 'color': Color(0xFF66BB6A)},
    {'name': 'Vector-borne Diseases', 'icon': Icons.pest_control, 'color': Color(0xFFFFA726)},
    {'name': 'Water-borne Diseases', 'icon': Icons.water_drop, 'color': Color(0xFF42A5F5)},
    {'name': 'Respiratory Diseases', 'icon': Icons.air, 'color': Color(0xFFAB47BC)},
    {'name': 'Chronic Diseases', 'icon': Icons.accessibility_new, 'color': Color(0xFF78909C)},
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'Explore Health',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
            ),
            floating: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FloatingActionButton.small(
                  heroTag: 'ai_fab',
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.smart_toy, color: AppColors.primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SwasthAiScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  return _buildCategoryCard(context, cat);
                },
                childCount: categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding for floating nav
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(
            color: (cat['color'] as Color).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseCategoryScreen(categoryName: cat['name']),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'], size: 32, color: cat['color']),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  cat['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
