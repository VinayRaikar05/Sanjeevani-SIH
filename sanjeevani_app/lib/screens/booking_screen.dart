import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  const BookingScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService _apiService = ApiService();
  String? _selectedTimeslot;
  bool _isLoading = false;

  final List<String> _timeSlots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'];

  void _confirmBooking() async {
    if (_selectedTimeslot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // --- THIS IS THE LOGIC FIX ---
      // We now get the full user object, and then get the id from it.
      final patientId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (patientId == null) throw Exception('User not logged in!');
      // --- END OF FIX ---

      await _apiService.bookAppointment(
        doctorId: widget.doctor.id,
        timeslot: _selectedTimeslot!,
        patientId: patientId,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
        (Route<dynamic> route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (The UI for this screen remains the same as before)
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctor.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.doctor.specialization, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 32),
            Text('Select a Time Slot', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: _selectedTimeslot == time,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedTimeslot = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
