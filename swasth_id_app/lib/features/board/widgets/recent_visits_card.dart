import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class RecentVisitsCard extends StatelessWidget {
  final List<dynamic> visits;
  final VoidCallback onViewAll;

  // Constructor accepts list, we handle logic inside
  const RecentVisitsCard({
    super.key,
    required this.visits,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) return const SizedBox.shrink(); // Hide if no data

    // Get most recent visit
    final recentVisit = visits.first;
    
    // Extract advice (Mocking extraction logic as backend might not separate it cleanly yet)
    // We look for 'prescription_url' presence or 'notes' if available in future
    final String doctorAdvice = recentVisit['notes'] ?? 
        "Stay hydrated and complete the prescribed medication course.";
    
    // Parse Date
    final dateStr = recentVisit['created_at'] ?? DateTime.now().toIso8601String();
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    
    final facility = recentVisit['facility_name'] ?? 'Unknown Facility';
    final type = recentVisit['visit_type'] ?? 'General';

    return Column(
      children: [
        // SECTION 3: LAST DOCTOR ADVICE (Trust Builder)
        Card(
          elevation: 4,
          shadowColor: Colors.teal.withOpacity(0.2),
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: Colors.teal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Last Doctor Advice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"$doctorAdvice"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // SECTION 4: RECENT DOCTOR VISIT (Single)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            onTap: onViewAll, // In future, link to specific visit detail
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Visit',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_hospital, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$formattedDate • $type',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(type),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String type) {
    Color color;
    String label;

    if (type.toLowerCase().contains('follow')) {
      color = Colors.orange;
      label = 'Follow-up';
    } else if (type.toLowerCase().contains('refer')) {
      color = Colors.red;
      label = 'Referred';
    } else {
      color = Colors.green;
      label = 'Normal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
