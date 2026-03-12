import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/auth/login_screen.dart';
import 'package:swasth_id_app/features/doctor/patient_summary_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final _manualIdController = TextEditingController();
  final _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _hasScanned = false;
  List<String> _recentPatients = [];
  String _doctorName = 'Doctor';

  @override
  void initState() {
    super.initState();
    _loadRecentPatients();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobile') ?? '';
    setState(() {
      _recentPatients = prefs.getStringList('doctor_recent_patients') ?? [];
      if (mobile.isNotEmpty) _doctorName = 'Dr. ($mobile)';
    });
  }

  Future<void> _saveRecentPatient(String healthId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('doctor_recent_patients') ?? [];
    list.remove(healthId); // Remove duplicate
    list.insert(0, healthId); // Add to front
    if (list.length > 10) list.removeLast(); // Keep max 10
    await prefs.setStringList('doctor_recent_patients', list);
    setState(() => _recentPatients = list);
  }

  void _onScan(String? code) {
    if (_hasScanned || code == null || code.isEmpty) return;
    setState(() => _hasScanned = true);
    _navigateToSummary(code);
  }

  void _navigateToSummary(String healthId) {
    if (healthId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Health ID')),
      );
      return;
    }
    _saveRecentPatient(healthId.trim());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientSummaryScreen(healthId: healthId.trim()),
      ),
    ).then((_) => setState(() => _hasScanned = false));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScannerCard(),
                  const SizedBox(height: 16),
                  _buildOrDivider(),
                  const SizedBox(height: 16),
                  _buildManualSearch(),
                  const SizedBox(height: 24),
                  if (_recentPatients.isNotEmpty) _buildRecentPatients(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Doctor Dashboard',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _doctorName,
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildScannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'SCAN PATIENT QR CODE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryColor, letterSpacing: 0.8),
                    ),
                  ],
                ),
                // Scanner toggle
                Switch(
                  value: _isScanning,
                  onChanged: (v) {
                    setState(() => _isScanning = v);
                    if (v) {
                      _scannerController.start();
                    } else {
                      _scannerController.stop();
                    }
                  },
                  activeColor: AppColors.tealAccent,
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: SizedBox(
              height: 260,
              child: _isScanning
                  ? Stack(
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            for (final barcode in capture.barcodes) {
                              if (barcode.rawValue != null) {
                                _onScan(barcode.rawValue);
                                break;
                              }
                            }
                          },
                        ),
                        // Scan overlay
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Point camera at patient\'s QR code',
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_rounded, size: 72, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Scanner is off', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR ENTER MANUALLY',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 0.6),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // --------------------------------------------------
  Widget _buildManualSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'MANUAL HEALTH ID LOOKUP',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualIdController,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Paste or type Health ID (UUID)',
              prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryColor),
              filled: true,
              fillColor: AppColors.backgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (v) => _navigateToSummary(v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _navigateToSummary(_manualIdController.text.trim()),
              icon: const Icon(Icons.person_search_rounded),
              label: const Text('View Patient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildRecentPatients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'RECENT PATIENTS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.7),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('doctor_recent_patients');
                setState(() => _recentPatients = []);
              },
              child: const Text('Clear', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...(_recentPatients.take(5).toList().asMap().entries.map((entry) {
          final id = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _navigateToSummary(id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outlined, color: AppColors.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Patient', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            id.length > 20 ? '${id.substring(0, 20)}...' : id,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          );
        })).toList(),
      ],
    );
  }
}
