// Defines the structure for a single appointment object.
class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final String timeslot;
  final String status;
  final String patientName;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.timeslot,
    required this.status,
    required this.patientName,
    required this.createdAt,
  });

  // A factory constructor to create an Appointment from the JSON data
  // our backend sends us.
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      timeslot: json['timeslot'],
      status: json['status'],
      patientName: json['patientName'] ?? 'Unknown Patient',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
