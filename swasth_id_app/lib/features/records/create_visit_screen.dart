import 'package:flutter/material.dart';
import 'package:swasth_id_app/features/records/services/visit_service.dart';

class CreateVisitScreen extends StatefulWidget {
  final String healthId;
  const CreateVisitScreen({super.key, required this.healthId});

  @override
  State<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends State<CreateVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _facilityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _complaintController = TextEditingController();
  
  // Vitals
  final _tempController = TextEditingController();
  final _bpController = TextEditingController();
  final _spo2Controller = TextEditingController();
  
  // Vaccination
  bool _vaccineGiven = false;
  final _vaccineNameController = TextEditingController();
  final _vaccineDateController = TextEditingController();
  
  // Referral
  bool _referred = false;
  final _referredToController = TextEditingController();
  final _referralReasonController = TextEditingController();
  
  String _visitType = 'OPD';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await VisitService.createVisit(
      healthId: widget.healthId,
      facilityName: _facilityController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      visitType: _visitType,
      chiefComplaint: _complaintController.text.trim(),
      
      temperature: double.tryParse(_tempController.text.trim()),
      bp: _bpController.text.trim().isEmpty ? null : _bpController.text.trim(),
      spo2: int.tryParse(_spo2Controller.text.trim()),
      
      vaccineGiven: _vaccineGiven,
      vaccineName: _vaccineGiven ? _vaccineNameController.text.trim() : null,
      nextDoseDate: _vaccineGiven ? _vaccineDateController.text.trim() : null,
      
      referred: _referred,
      referredTo: _referred ? _referredToController.text.trim() : null,
      referralReason: _referred ? _referralReasonController.text.trim() : null,
    );
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visit Created Successfully')),
      );
      Navigator.pop(context, true); // Return success
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _facilityController,
                decoration: const InputDecoration(labelText: 'Facility Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _visitType,
                items: ['OPD', 'Emergency', 'Referral']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _visitType = v!),
                decoration: const InputDecoration(labelText: 'Visit Type'),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _complaintController,
                decoration: const InputDecoration(labelText: 'Chief Complaint'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),
              
              const Text('Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      decoration: const InputDecoration(labelText: 'Temp (°C)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bpController,
                      decoration: const InputDecoration(labelText: 'BP (e.g 120/80)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _spo2Controller,
                      decoration: const InputDecoration(labelText: 'SpO2 (%)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              SwitchListTile(
                title: const Text('Vaccination Given?'),
                value: _vaccineGiven,
                onChanged: (v) => setState(() => _vaccineGiven = v),
              ),
              if (_vaccineGiven) ...[
                TextFormField(
                  controller: _vaccineNameController,
                  decoration: const InputDecoration(labelText: 'Vaccine Name'),
                ),
                TextFormField(
                  controller: _vaccineDateController,
                  decoration: const InputDecoration(labelText: 'Next Dose Due Date (YYYY-MM-DD)'),
                ),
              ],
              
              SwitchListTile(
                title: const Text('Referred?'),
                value: _referred,
                onChanged: (v) => setState(() => _referred = v),
              ),
              if (_referred) ...[
                TextFormField(
                  controller: _referredToController,
                  decoration: const InputDecoration(labelText: 'Referred To (Hospital/Doctor)'),
                ),
                TextFormField(
                  controller: _referralReasonController,
                  decoration: const InputDecoration(labelText: 'Reason for Referral'),
                ),
              ],
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Create Visit Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
