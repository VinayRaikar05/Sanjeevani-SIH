// This class defines the structure for a single medicine entry.
class Medicine {
  String name;
  String dosage; // e.g., "500mg"
  String frequency; // e.g., "1-0-1" (morning-afternoon-night)

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  // This is the special method that converts our Medicine object into a JSON map.
  // This is the "official form" format that our backend API can understand.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }

  // Factory method to create a Medicine object from JSON data
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
    );
  }
}

