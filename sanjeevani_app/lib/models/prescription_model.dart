import 'medicine_model.dart';

// This class defines the structure for a full prescription object.
class Prescription {
  final int id;
  final int appointmentId;
  final int patientId;
  final int doctorId;
  final List<Medicine> medicines;
  final String? notes;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.medicines,
    this.notes,
    required this.createdAt,
  });

  // We are adding this factory method so we can easily create a Prescription
  // object from the JSON data we will get from our backend.
  factory Prescription.fromJson(Map<String, dynamic> json) {
    // This part is a bit complex. The 'medicines' field in the JSON is a list of maps.
    // We need to loop through that list and convert each map into a Medicine object.
    var medicinesList = json['medicines'] as List;
    List<Medicine> medicineObjects = medicinesList.map((medJson) => Medicine.fromJson(medJson)).toList();

    return Prescription(
      id: json['id'],
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      medicines: medicineObjects,
      notes: json['notes'],
      // The date from the database comes as a string, so we need to parse it into a DateTime object.
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// We also need to add a .fromJson constructor to our Medicine model
// to make the above code work. Please update your medicine_model.dart as well.
// I will provide the full code for that file in the next response if needed.

