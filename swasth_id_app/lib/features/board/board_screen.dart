import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/auth/login_screen.dart';
import 'package:swasth_id_app/features/board/widgets/activity_card.dart';
import 'package:swasth_id_app/features/board/widgets/body_health_card.dart';
import 'package:swasth_id_app/features/board/widgets/health_status_card.dart';
import 'package:swasth_id_app/features/board/widgets/quick_actions_grid.dart';
import 'package:swasth_id_app/features/board/widgets/recent_visits_card.dart';
import 'package:swasth_id_app/services/api_service.dart';
import 'package:swasth_id_app/features/records/services/visit_service.dart';
import 'package:swasth_id_app/widgets/gradient_scaffold.dart';
// Import feature screens for navigation
// import 'package:swasth_id_app/features/records/records_screen.dart'; // Just tab switching
// import 'package:swasth_id_app/features/ai_chat/ai_chat_screen.dart'; // If exists

class BoardScreen extends StatefulWidget {
  final Function(int)? onTabChange; // Callback to switch bottom nav tabs

  const BoardScreen({super.key, this.onTabChange});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  bool _isLoading = true;
  String? _healthId;
  String _mobile = ''; // Store mobile for display
  Map<String, dynamic>? _profileData;
  List<dynamic> _visits = [];
  String _district = 'Unknown';
  int _age = 25; // Default
  String _alertLevel = 'LOW';

  @override
  void initState() {
    super.initState();
    _fetchBoardData();
  }

  // Helper helper to safe parse numbers
  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _fetchBoardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Get Mobile
      String mobile = prefs.getString('mobile') ?? '';
      if (mounted) setState(() => _mobile = mobile); // Update UI
      
      print('DEBUG: Fetching Board Data for Mobile: $mobile');

      if (mobile.isEmpty) {
         print('DEBUG: No mobile found in prefs. Using fallback.');
         mobile = '9444529010'; // Fallback
         if (mounted) setState(() => _mobile = '$mobile (Fallback)');
      }
      
      // 2. Get Health ID
      print('DEBUG: Calling confirmIdVerification...');
      final idResult = await ApiService.confirmIdVerification(
        mobile: mobile,
        idType: 'Aadhaar', 
        idNumber: '000000000000', 
      );
      print('DEBUG: confirmIdVerification result: $idResult');

      if (idResult['success'] == true || idResult.containsKey('health_id')) {
        _healthId = idResult['health_id'] ?? idResult['data']?['health_id'];
        print('DEBUG: Got Health ID: $_healthId');
        
        if (_healthId != null) {
          // 3. Fetch Profile
          print('DEBUG: Fetching Profile...');
          final profileResult = await ApiService.getPatientProfile(_healthId!);
          print('DEBUG: Profile Result: $profileResult');

          if (profileResult['success'] == true) {
            final data = profileResult['data'];
            if (mounted) {
              setState(() {
                _profileData = data['medical_details'];
                Map<String, dynamic> personal = data['personal_details'] ?? {};
                _district = personal['city'] ?? 'Trivandrum';
                _age = personal['age'] ?? 25; 
                _alertLevel = 'LOW'; 
              });
            }
          } else {
             print('DEBUG: Failed to fetch profile: ${profileResult['message']}');
          }

          // 4. Fetch Visits
          try {
            final visits = await VisitService.getVisits(_healthId!);
            if (mounted) {
              setState(() {
                _visits = visits;
              });
            }
          } catch (e) {
            print('Error fetching visits: $e');
          }
        }
      } else {
        print('DEBUG: Failed to get Health ID');
      }
    } catch (e) {
      print('Error loading board: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRecords() {
    // If we have a callback to switch tabs, use it (Records is usually index 1)
    if (widget.onTabChange != null) {
      widget.onTabChange!(1); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Switched to Records Tab')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBoardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 100),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'My Health Board',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'User: $_mobile', // Debug info
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        // Profile Icon & Logout
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.redAccent),
                              onPressed: _handleLogout,
                              tooltip: 'Logout',
                            ),
                            Container(
                               padding: const EdgeInsets.all(2),
                               decoration: BoxDecoration(
                                 border: Border.all(color: AppColors.primaryColor, width: 2),
                                 shape: BoxShape.circle,
                               ),
                               child: const CircleAvatar(
                                 radius: 20,
                                 backgroundColor: Colors.grey, 
                                 child: Icon(Icons.person, color: Colors.white),
                               ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. Health Status (District Alert)
                    HealthStatusCard(
                      district: _district,
                      alertLevel: _alertLevel,
                    ),
                    const SizedBox(height: 16),

                    // 2. Body Health (BMI + Ideal Weight)
                    BodyHealthCard(
                      heightCm: _safeParseDouble(_profileData?['height_cm']),
                      weightKg: _safeParseDouble(_profileData?['weight_kg']),
                      age: _age, 
                      bmi: _safeParseDouble(_profileData?['bmi']),
                    ),
                    const SizedBox(height: 16),

                    // 3. Activity (Real Pedometer)
                    const ActivityCard(),
                    const SizedBox(height: 16),

                    // 4. Recent Visits (Advice + Single)
                    RecentVisitsCard(
                      visits: _visits,
                      onViewAll: _navigateToRecords,
                    ),
                    const SizedBox(height: 24),

                    // 5. Quick Actions
                    QuickActionsGrid(
                      onRecordsTap: _navigateToRecords,
                      onAiTap: () {
                         // Navigation logic for Swasth AI
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Swasth AI...')),
                        );
                      },
                      onUploadTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upload Document feature coming soon')),
                        );
                      },
                      onPhcTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Finding nearby PHC...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
