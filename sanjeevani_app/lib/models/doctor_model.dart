// This class defines the structure of a 'Doctor' object.
class Doctor {
  final int id;
  final String name;
  final String specialization;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
  });

  // This is a factory constructor that creates a Doctor instance from a JSON map.
  // This is crucial for parsing the data we get from our backend API.
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
    );
  }
}
