import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onRecordsTap;
  final VoidCallback onAiTap;
  final VoidCallback onUploadTap;
  final VoidCallback onPhcTap;

  const QuickActionsGrid({
    super.key,
    required this.onRecordsTap,
    required this.onAiTap,
    required this.onUploadTap,
    required this.onPhcTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5, // Wider buttons
          children: [
            _buildActionButton(
              'View Records',
              Icons.folder_shared_outlined,
              Colors.blue,
              onRecordsTap,
            ),
            _buildActionButton(
              'Swasth AI',
              Icons.auto_awesome_outlined,
              Colors.purple,
              onAiTap,
            ),
            _buildActionButton(
              'Upload Doc',
              Icons.upload_file,
              Colors.orange,
              onUploadTap,
            ),
            _buildActionButton(
              'Nearby PHC',
              Icons.local_hospital_outlined,
              Colors.green,
              onPhcTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
