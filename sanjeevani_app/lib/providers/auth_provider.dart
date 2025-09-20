// The 'i' in 'import' has been corrected.
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;

  bool get isLoggedIn => _currentUser != null && _currentUser!.role != 'UNKNOWN';
  AppUser? get user => _currentUser;

  void login(AppUser user) {
    print('AuthProvider - Logging in user: $user');
    print('AuthProvider - User role: ${user.role}');
    _currentUser = user;
    notifyListeners();
    print('AuthProvider - Notified listeners, current user: $_currentUser');
  }

  void logout() {
    print('AuthProvider - Logging out user');
    _currentUser = null;
    notifyListeners();
  }
}
