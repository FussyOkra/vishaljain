import 'package:flutter/material.dart';
import 'package:swasth_id_app/core/constants/app_colors.dart';
import 'package:swasth_id_app/features/doctor/services/doctor_api_service.dart';
import 'package:swasth_id_app/features/doctor/visit_history_screen.dart';
import 'package:swasth_id_app/features/doctor/add_visit_screen.dart';

class PatientSummaryScreen extends StatefulWidget {
  final String healthId;
  const PatientSummaryScreen({super.key, required this.healthId});

  @override
  State<PatientSummaryScreen> createState() => _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends State<PatientSummaryScreen> {
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _personal = {};
  Map<String, dynamic> _medical = {};
  List<dynamic> _visits = [];
  Map<String, dynamic> _aiSummary = {};

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Parallel fetch: profile + visits + AI summary
    final results = await Future.wait([
      DoctorApiService.getPatientProfile(widget.healthId),
      DoctorApiService.getPatientVisits(widget.healthId),
      DoctorApiService.getAiSummary(widget.healthId),
    ]);

    final profileResult = results[0];
    final visitsResult = results[1];
    final aiResult = results[2];

    if (!mounted) return;

    if (!profileResult['success']) {
      setState(() {
        _isLoading = false;
        _error = profileResult['message'] ?? 'Failed to load patient data';
      });
      return;
    }

    setState(() {
      _isLoading = false;
      final data = profileResult['data'] as Map<String, dynamic>;
      _personal = data['personal_details'] ?? {};
      _medical = data['medical_details'] ?? {};
      _visits = (visitsResult['data'] as List?) ?? [];
      _aiSummary = (aiResult['data'] as Map<String, dynamic>?) ?? {};
    });
  }

  String get _patientName => (_personal['name'] ?? 'Patient').toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: AppColors.textColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoading ? 'Loading...' : _patientName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Health ID: ${widget.healthId.length > 8 ? widget.healthId.substring(0, 8) + '...' : widget.healthId}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchAll,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientSnapshot(),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        const SizedBox(height: 16),
                        _buildAiSummaryCard(),
                        const SizedBox(height: 16),
                        _buildVisitPreview(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SECTION 1 — Patient Snapshot
  // --------------------------------------------------
  Widget _buildPatientSnapshot() {
    return _SectionCard(
      title: 'PATIENT SNAPSHOT',
      icon: Icons.person_pin_outlined,
      iconColor: AppColors.primaryColor,
      child: Column(
        children: [
          // Avatar + Name header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _patientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      '${_personal['age'] ?? '-'} yrs • ${_personal['gender'] ?? '-'}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Medical chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HealthChip(
                label: _medical['blood_group'] ?? 'N/A',
                icon: Icons.bloodtype,
                color: Colors.red,
              ),
              _HealthChip(
                label: 'BMI ${_medical['bmi'] ?? '-'}',
                icon: Icons.monitor_weight_outlined,
                color: Colors.orange,
              ),
              _HealthChip(
                label: _medical['vaccination_status'] ?? 'N/A',
                icon: Icons.vaccines,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info rows
          _InfoRow(label: 'Height', value: '${_medical['height_cm'] ?? '-'} cm'),
          _InfoRow(label: 'Weight', value: '${_medical['weight_kg'] ?? '-'} kg'),
          _InfoRow(
            label: 'Allergies',
            value: _medical['allergies']?.toString().isNotEmpty == true
                ? _medical['allergies'].toString()
                : 'None reported',
            isAlert: (_medical['allergies']?.toString() ?? 'none').toLowerCase() != 'none' &&
                (_medical['allergies']?.toString() ?? '').isNotEmpty,
          ),
          _InfoRow(label: 'Address', value: '${_personal['city'] ?? '-'}, ${_personal['state'] ?? '-'}'),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION 2 — Quick Actions
  // --------------------------------------------------
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.history_rounded,
            label: 'Visit History',
            color: AppColors.primaryColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitHistoryScreen(
                  healthId: widget.healthId,
                  patientName: _patientName,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Visit',
            color: AppColors.tealAccent,
            onTap: () async {
              final refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddVisitScreen(
                    healthId: widget.healthId,
                    patientName: _patientName,
                  ),
                ),
              );
              if (refreshed == true) _fetchAll();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.folder_open_rounded,
            label: 'Records',
            color: const Color(0xFF7C3AED),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitHistoryScreen(
                  healthId: widget.healthId,
                  patientName: _patientName,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SECTION 3 — AI Medical Summary
  // --------------------------------------------------
  Widget _buildAiSummaryCard() {
    return _SectionCard(
      title: 'AI MEDICAL SUMMARY',
      icon: Icons.auto_awesome,
      iconColor: const Color(0xFF7C3AED),
      headerTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'AI Powered',
          style: TextStyle(fontSize: 10, color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
        ),
      ),
      child: Column(
        children: [
          _AiRow(icon: Icons.medical_information_outlined, label: 'Chronic Conditions', value: _aiSummary['chronic_conditions'] ?? '—'),
          const Divider(height: 20),
          _AiRow(icon: Icons.sick_outlined, label: 'Recent Illness', value: _aiSummary['recent_illness'] ?? '—'),
          const Divider(height: 20),
          _AiRow(icon: Icons.biotech_outlined, label: 'Recent Tests', value: _aiSummary['recent_tests'] ?? '—'),
          const Divider(height: 20),
          _AiRow(icon: Icons.summarize_outlined, label: 'Last Visit Summary', value: _aiSummary['last_visit_summary'] ?? '—'),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION 4 — Visit History Preview (latest 3)
  // --------------------------------------------------
  Widget _buildVisitPreview(BuildContext context) {
    final preview = _visits.take(3).toList();

    return _SectionCard(
      title: 'VISIT HISTORY PREVIEW',
      icon: Icons.timeline_rounded,
      iconColor: AppColors.tealAccent,
      headerTrailing: _visits.isNotEmpty
          ? TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitHistoryScreen(
                    healthId: widget.healthId,
                    patientName: _patientName,
                  ),
                ),
              ),
              child: const Text('View All', style: TextStyle(color: AppColors.tealAccent)),
            )
          : null,
      child: preview.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No visits recorded yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : Column(
              children: preview.asMap().entries.map((entry) {
                final v = entry.value;
                final date = v['created_at']?.toString().split('T')[0] ?? 'Unknown date';
                final doctor = v['doctor_name'] ?? 'Unknown Doctor';
                final complaint = v['chief_complaint'] ?? v['symptoms'] ?? 'Consultation';
                final type = v['visit_type'] ?? 'OPD';
                final isLast = entry.key == preview.length - 1;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.tealAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_hospital_outlined, color: AppColors.tealAccent, size: 22),
                      ),
                      title: Text(
                        complaint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Dr. $doctor • $date',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(type, style: const TextStyle(fontSize: 10, color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

// ===========================================================
// REUSABLE LOCAL WIDGETS
// ===========================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? headerTrailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.headerTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const _InfoRow({required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isAlert ? AppColors.error : AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _HealthChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AiRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textColor)),
            ],
          ),
        ),
      ],
    );
  }
}
