import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';

class HealthStatusCard extends StatelessWidget {
  final String district;
  
  // Later this can be dynamic based on backend
  final String alertLevel; 

  const HealthStatusCard({
    super.key,
    required this.district,
    required this.alertLevel,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color and message based on alert level
    Color cardColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String message;

    switch (alertLevel.toUpperCase()) {
      case 'HIGH':
        cardColor = const Color(0xFFE57373); // Red lighten-2
        textColor = Colors.white;
        icon = Icons.warning_rounded;
        statusTitle = 'High Alert';
        message = 'Significant illness cases reported in $district. Take precautions.';
        break;
      case 'MEDIUM':
        cardColor = const Color(0xFFFFF176); // Yellow lighten-2
        textColor = Colors.black87;
        icon = Icons.info_outline;
        statusTitle = 'District Under Watch';
        message = 'Seasonal illness cases reported in $district. Stay cautious.';
        break;
      case 'LOW':
      default:
        cardColor = const Color(0xFFA5D6A7); // Green lighten-2
        textColor = Colors.black87;
        icon = Icons.verified_user_outlined;
        statusTitle = 'You are Safe';
        message = 'No major health alerts in $district.';
        break;
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
