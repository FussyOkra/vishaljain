import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';

class BodyHealthCard extends StatelessWidget {
  final double? heightCm;
  final double? weightKg;
  final int? age;
  final double? bmi; 

  const BodyHealthCard({
    super.key,
    this.heightCm,
    this.weightKg,
    this.age,
    this.bmi,
  });

  @override
  Widget build(BuildContext context) {
    if (heightCm == null || weightKg == null) {
      return _buildEmptyState();
    }

    // 1. BMI Logic
    final double actualBmi = bmi ?? (weightKg! / ((heightCm! / 100) * (heightCm! / 100)));
    final String bmiString = actualBmi.toStringAsFixed(1);

    String status;
    Color statusColor;
    String largeMessage;

    if (actualBmi < 18.5) {
      status = 'Underweight';
      statusColor = Colors.orangeAccent;
      largeMessage = 'You are Underweight';
    } else if (actualBmi >= 18.5 && actualBmi <= 24.9) {
      status = 'Fit';
      statusColor = Colors.green;
      largeMessage = 'You are Fit';
    } else if (actualBmi >= 25 && actualBmi <= 29.9) {
      status = 'Overweight';
      statusColor = Colors.orange;
      largeMessage = 'You are Overweight';
    } else {
      status = 'Obese';
      statusColor = Colors.redAccent;
      largeMessage = 'You are Obese';
    }

    // 2. Ideal Weight Logic (Formula: 22 * h^2)
    final double heightM = heightCm! / 100;
    final double idealWeight = 22 * heightM * heightM;
    final double minWeight = 18.5 * heightM * heightM;
    final double maxWeight = 24.9 * heightM * heightM;
    
    final String idealRange = '${minWeight.round()} - ${maxWeight.round()} kg';

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Body Health Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Large Status Message
            Center(
              child: Text(
                largeMessage,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Height', '${heightCm!.round()} cm'),
                _buildMetric('Weight', '$weightKg kg'),
                _buildMetric('Age', '$age yrs'),
                _buildMetric('BMI', bmiString, isHighlight: true, highlightColor: statusColor),
              ],
            ),
            const SizedBox(height: 24),

            // Ideal Weight Box
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.withOpacity(0.05), Colors.blue.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ideal weight: ${idealWeight.round()} kg',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target Range: $idealRange',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isHighlight ? highlightColor : AppColors.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_outline, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text('Update your profile to see health insights'),
            ],
          ),
        ),
      ),
    );
  }
}
