import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/records/visit_list_screen.dart';
import 'package:swasth_id_app/features/swasth_ai/swasth_ai_screen.dart';
import 'package:swasth_id_app/widgets/glass_container.dart';
import 'package:swasth_id_app/widgets/gradient_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Space for floating nav
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthCard(),
                  const SizedBox(height: 24),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickGrid(context),
                  const SizedBox(height: 24),
                  const Text(
                    "Recent Updates",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentUpdateCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Text(
                  "Swasth User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Swasth ID",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  "HID-123456",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Active & Verified",
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.tealAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code, size: 40, color: AppColors.tealAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.smart_toy,
        'label': 'Swasth AI',
        'color': const Color(0xFF6C63FF),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SwasthAiScreen()))
      },
      {
        'icon': Icons.article_outlined,
        'label': 'Records',
        'color': AppColors.primaryColor,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitListScreen()))
      },
      {
        'icon': Icons.local_hospital_outlined,
        'label': 'Doctors',
        'color': AppColors.tealAccent,
        'onTap': () {} // Todo
      },
      {
        'icon': Icons.medication_outlined,
        'label': 'Medicines',
        'color': Colors.orange,
        'onTap': () {} // Todo
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: item['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (item['color'] as Color).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                ),
                const SizedBox(height: 12),
                Text(
                  item['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentUpdateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upcoming Vaccination",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "COVID-19 Booster • 2 Days left",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
