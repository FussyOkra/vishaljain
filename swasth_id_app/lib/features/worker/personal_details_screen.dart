import 'package:flutter/material.dart';
import 'package:swasth_id_app/services/api_service.dart';
import 'package:swasth_id_app/features/worker/medical_details_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String mobile;
  const PersonalDetailsScreen({super.key, required this.mobile});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  String _gender = 'Male';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await ApiService.submitPersonalDetails(
      mobile: widget.mobile,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _gender,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
    );
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalDetailsScreen(mobile: widget.mobile),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 1: Personal Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: ['Male', 'Female', 'Other']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                 controller: _stateController,
                 decoration: const InputDecoration(labelText: 'State'),
                 validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.length != 6 ? '6 digits required' : null,
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('Next: Medical Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
