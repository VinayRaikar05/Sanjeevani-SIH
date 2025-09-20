import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../models/medicine_model.dart';
import '../models/appointment_model.dart'; // <-- New import

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      // --- THIS IS THE CRITICAL FIX ---
      // The URL is now a simple, correct string without any extra characters.
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // --- THIS IS THE NEW METHOD ---
  Future<List<Appointment>> getDoctorAppointments(int doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/doctor/$doctorId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Appointment> appointments = body
            .map((dynamic item) => Appointment.fromJson(item))
            .toList();
        return appointments;
      } else {
        throw Exception(
          'Failed to load appointments. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server. Is your backend running? Error: $e',
      );
    }
  }
  // --- END OF NEW METHOD ---

  // ... (all other methods like verifyOtp, getDoctors, bookAppointment, etc. remain the same)
  Future<Map<String, dynamic>> verifyOtpWithBackend(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'idToken': idToken}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to verify with backend: ${errorBody['message']}');
    }
  }

  Future<void> setUserRole({
    required String phoneNumber,
    required String role,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/set-role'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneNumber,
        'role': role,
        'name': name,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set user role: ${response.body}');
    }
  }

  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Doctor> doctors = body
            .map((dynamic item) => Doctor.fromJson(item))
            .toList();
        return doctors;
      } else {
        throw Exception(
          'Failed to load doctors. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server. Is your backend running? Error: $e',
      );
    }
  }

  Future<Map<String, dynamic>> bookAppointment({
    required int doctorId,
    required String timeslot,
    required int patientId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/book'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'doctorId': doctorId,
          'timeslot': timeslot,
          'patientId': patientId,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to book appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server. Is your backend running? Error: $e',
      );
    }
  }

  Future<void> createPrescription({
    required int appointmentId,
    required int patientId,
    required int doctorId,
    required List<Medicine> medicines,
    required String notes,
  }) async {
    final List<Map<String, dynamic>> medicinesJson = medicines
        .map((med) => med.toJson())
        .toList();
    final response = await http.post(
      Uri.parse('$baseUrl/prescriptions/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'appointmentId': appointmentId,
        'patientId': patientId,
        'doctorId': doctorId,
        'medicines': medicinesJson,
        'notes': notes,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create prescription: ${response.body}');
    }
  }
}
