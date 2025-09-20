import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart' as app;

class RoleSelectionScreen extends StatefulWidget {
  final AppUser user;
  const RoleSelectionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? _selectedRole;
  bool _isLoading = false;

  void _submitRole() async {
    if (_nameController.text.isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name and select a role.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _apiService.setUserRole(
        phoneNumber: widget.user.phoneNumber,
        role: _selectedRole!,
        name: _nameController.text,
      );
      
      final updatedUser = AppUser(
        id: widget.user.id,
        name: _nameController.text,
        phoneNumber: widget.user.phoneNumber,
        role: _selectedRole!,
      );
      Provider.of<app.AuthProvider>(context, listen: false).login(updatedUser);
      // The wrapper will now navigate to the correct home screen automatically.

    } catch (e) {
      // This is our clean, standard error message.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed. Please try again. Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('One Last Step!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Please tell us who you are.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'I am a...', border: OutlineInputBorder()),
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'PATIENT', child: Text('Patient')),
                  DropdownMenuItem(value: 'DOCTOR', child: Text('Doctor')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRole,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Registration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
