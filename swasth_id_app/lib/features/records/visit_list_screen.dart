import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/records/create_visit_screen.dart';
import 'package:swasth_id_app/features/records/services/visit_service.dart';
import 'package:swasth_id_app/features/records/visit_detail_screen.dart';
import 'package:swasth_id_app/widgets/glass_container.dart';
import 'package:swasth_id_app/widgets/gradient_scaffold.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  List<dynamic> _visits = [];
  bool _isLoading = true;
  String? _healthId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealthIdAndVisits();
  }

  Future<void> _loadHealthIdAndVisits() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Fallback: Try to use mobile if health_id not explicitly saved in previous steps
    // But for this UI demo, we assume the user has a health_id or we use a dummy if needed
    // logic remains same as before to keep integration safe.
    final storedHealthId = prefs.getString('health_id');
    
    if (storedHealthId != null) {
      _healthId = storedHealthId;
      _fetchVisits();
    } else {
      // Logic from before: handle error
      setState(() {
         // If we are testing UI and stuck, we could hint the user, but let's stick to true logic
         _error = "Health ID not found. Return to Home."; 
         _isLoading = false;
      });
    }
  }

  Future<void> _fetchVisits() async {
    try {
      final visits = await VisitService.getVisits(_healthId!);
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {}, // Todo: Filter
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_healthId == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateVisitScreen(healthId: _healthId!),
            ),
          );
          if (result == true) {
            _fetchVisits();
          }
        },
        label: const Text('Add Record'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.primaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No records found',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length,
      itemBuilder: (context, index) {
        final visit = _visits[index];
        return _buildVisitCard(visit);
      },
    );
  }

  Widget _buildVisitCard(dynamic visit) {
    final date = visit['created_at'] != null 
        ? visit['created_at'].toString().split('T')[0] 
        : 'Unknown Date';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitDetailScreen(visit: visit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tealAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'OPD Visit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                     Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit['facility_name'] ?? 'Unknown Facility',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            visit['chief_complaint'] ?? 'No Complaint',
                            style: const TextStyle(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
