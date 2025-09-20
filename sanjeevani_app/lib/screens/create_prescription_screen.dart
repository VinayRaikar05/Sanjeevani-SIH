import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/api_service.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  // These details will be passed from the video call screen
  final int patientId;
  final int doctorId;
  final int appointmentId;

  const CreatePrescriptionScreen({
    Key? key,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _CreatePrescriptionScreenState createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final ApiService _apiService = ApiService();
  final List<Medicine> _medicines = [];
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // This function shows a pop-up dialog to add a new medicine
  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Medicine Name')),
              TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Dosage (e.g., 500mg)')),
              TextField(controller: frequencyController, decoration: const InputDecoration(labelText: 'Frequency (e.g., 1-0-1)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _medicines.add(Medicine(
                      name: nameController.text,
                      dosage: dosageController.text,
                      frequency: frequencyController.text,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // This function handles submitting the final prescription to the backend
  void _submitPrescription() async {
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one medicine.')));
      return;
    }
    
    setState(() { _isLoading = true; });

    try {
      await _apiService.createPrescription(
        appointmentId: widget.appointmentId,
        patientId: widget.patientId,
        doctorId: widget.doctorId,
        medicines: _medicines,
        notes: _notesController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription submitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medicines', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(
                child: _medicines.isEmpty
                    ? const Center(child: Text('No medicines added yet.'))
                    : ListView.builder(
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final med = _medicines[index];
                          return Card(
                            child: ListTile(
                              title: Text(med.name),
                              subtitle: Text('${med.dosage}, Frequency: ${med.frequency}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _medicines.removeAt(index)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Additional Notes', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPrescription,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicineDialog,
        label: const Text('Add Medicine'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
