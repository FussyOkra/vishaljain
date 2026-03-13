import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({super.key});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late Stream<StepCount> _stepCountStream;
  String _steps = '0';
  String _status = 'Resting';
  bool _isExpanded = false; // To show manual entry

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
      _status = 'Walking';
    });
  }

  void _onStepCountError(error) {
    setState(() {
      _steps = '0'; // Sensor not available or permission denied
      _status = 'Manual Mode';
    });
  }

  Future<void> _requestPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _initPedometer();
    } else {
      // Open settings
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentSteps = int.tryParse(_steps) ?? 0;
    const int goal = 6000;
    final double progress = (currentSteps / goal).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
                GestureDetector(
                  onTap: _requestPermission,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_run, size: 14, color: Colors.teal),
                        SizedBox(width: 4),
                        Text(
                          _status,
                          style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Progress Row
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                      ),
                    ),
                    const Icon(Icons.accessibility_new_rounded, color: AppColors.tealAccent, size: 32),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$currentSteps ',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const TextSpan(
                              text: 'steps',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Goal: $goal',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Encouraging message
                      Text(
                        currentSteps < 100 ? 'Start walking to track!' : (currentSteps < goal ? 'Keep going!' : 'Goal Met! 🎉'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: currentSteps >= goal ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Manual Entry Toggle (Optional polish)
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Future: Implement manual add dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual entry coming in next update')),
                );
              },
              child: const Text(
                '+ Add Manually',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
