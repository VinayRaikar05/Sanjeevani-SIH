import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/auth_provider.dart' as app;
import '../services/api_service.dart';
import 'video_call_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<List<Appointment>> _futureAppointments;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Get the current doctor's ID from the AuthProvider
    final doctorId = Provider.of<app.AuthProvider>(
      context,
      listen: false,
    ).user?.id;
    if (doctorId != null) {
      // Fetch the appointments for this specific doctor
      _futureAppointments = _apiService.getDoctorAppointments(doctorId);
    } else {
      // Handle the unlikely case where the doctor's ID is not available
      _futureAppointments = Future.value([]);
    }
  }

  void _refreshAppointments() {
    final doctorId = Provider.of<app.AuthProvider>(
      context,
      listen: false,
    ).user?.id;
    if (doctorId != null) {
      setState(() {
        _futureAppointments = _apiService.getDoctorAppointments(doctorId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = Provider.of<app.AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<app.AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, Dr. ${doctor?.name}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Your Upcoming Appointments:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _futureAppointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final appointment = snapshot.data![index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Patient: ${appointment.patientName}'),
                          subtitle: Text('Time: ${appointment.timeslot}'),
                          trailing: ElevatedButton(
                            child: const Text('Start Call'),
                            onPressed: () {
                              final callID = "appt_${appointment.id}";

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoCallScreen(
                                    callID: callID,
                                    userID: doctor!.id.toString(),
                                    userName: doctor.name,
                                    isDoctor: true, // This user is a doctor
                                    patientIdForPrescription:
                                        appointment.patientId,
                                    doctorIdForPrescription: doctor.id,
                                    appointmentIdForPrescription:
                                        appointment.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('You have no upcoming appointments.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
