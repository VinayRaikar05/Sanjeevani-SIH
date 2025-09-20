class AppUser {
  final int id;
  final String name;
  final String phoneNumber;
  final String role; // Will be 'PATIENT', 'DOCTOR', or 'UNKNOWN'

  AppUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    print('Parsing user JSON: $json'); // Debug print
    
    // Handle null name case
    String userName = json['name'] ?? 'New User';
    if (userName == 'null' || userName.isEmpty) {
      userName = 'New User';
    }
    
    return AppUser(
      id: json['id'] ?? 0,
      name: userName,
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'UNKNOWN',
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, phoneNumber: $phoneNumber, role: $role)';
  }
}

