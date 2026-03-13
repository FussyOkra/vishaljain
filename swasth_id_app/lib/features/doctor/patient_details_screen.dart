import 'package:flutter/material.dart';
import 'package:swasth_id_app/services/api_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String healthId;
  const PatientDetailsScreen({super.key, required this.healthId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await ApiService.getPatientProfile(widget.healthId);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _data = result['data'];
        } else {
          _error = result['message'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    final personal = _data!['personal_details'] ?? {};
    final medical = _data!['medical_details'] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Record')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Details'),
            _buildRow('Name', personal['name']),
            _buildRow('Age', '${personal['age']}'),
            _buildRow('Gender', personal['gender']),
            _buildRow('Mobile', widget.healthId), // Using healthId as ID reference here
            _buildRow('Address', personal['address']),
            _buildRow('Location', '${personal['city']}, ${personal['state']}'),
            
            const Divider(height: 32),
            
            _buildSectionHeader('Medical Profile'),
            _buildRow('Height', '${medical['height_cm']} cm'),
            _buildRow('Weight', '${medical['weight_kg']} kg'),
            _buildRow('Blood Group', medical['blood_group']),
            _buildRow('Vaccination', medical['vaccination_status']),
            _buildRow('Allergies', medical['allergies']),
            
            // Placeholder for Visits (Future work)
            const Divider(height: 32),
            _buildSectionHeader('Visits'),
            const Center(
              child: Text(
                'No recent visits recorded',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
