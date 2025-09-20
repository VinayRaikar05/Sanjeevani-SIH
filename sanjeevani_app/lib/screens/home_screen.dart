import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor_model.dart';
import '../providers/auth_provider.dart'; // Corrected to use our app's provider
import '../services/api_service.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Doctor>> _futureDoctors;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureDoctors = _apiService.getDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _futureDoctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center( /* ... error handling ... */ );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Doctor doctor = snapshot.data![index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade50,
                      child: const Icon(Icons.person, color: Colors.teal, size: 30),
                    ),
                    title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(doctor.specialization),
                    trailing: ElevatedButton(
                      child: const Text('Join Call'),
                      onPressed: () {
                        // --- THIS IS THE LOGIC FIX ---
                        // We now get the full user object, and then get the id from it.
                        final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
                        if (currentUser == null) return; // Safety check
                        final patientId = currentUser.id;
                        final patientName = currentUser.name;
                        // --- END OF FIX ---

                        final appointmentId = DateTime.now().millisecondsSinceEpoch;
                        final callID = "appt_${patientId}_${doctor.id}_${appointmentId}";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoCallScreen(
                              callID: callID,
                              userID: patientId.toString(),
                              userName: patientName,
                              isDoctor: false, // Patients will see this screen
                              patientIdForPrescription: patientId,
                              doctorIdForPrescription: doctor.id,
                              appointmentIdForPrescription: appointmentId,
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: null, 
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No doctors found.'));
          }
        },
      ),
    );
  }
}
