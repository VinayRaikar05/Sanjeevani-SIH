import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
// We give our file a nickname 'app' to avoid name collisions.
import '../providers/auth_provider.dart' as app;
import 'wrapper.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        String? idToken = await userCredential.user!.getIdToken();
        // --- THIS IS THE CRITICAL FIX ---
        // The variable is now correctly spelled as '_apiService' with a capital S.
        final response = await _apiService.verifyOtpWithBackend(idToken!);
        
        // Debug: Print the response to see what we're getting
        print('Backend response: $response');
        
        // The API service now wraps the backend response under 'user' key
        final userJson = response['user'];
        final isNewUser = response['isNewUser'] as bool? ?? false;
        
        print('User JSON: $userJson');
        print('Is new user: $isNewUser');
        
        final user = AppUser.fromJson(userJson);
        print('Parsed user: $user');
        print('User role: ${user.role}');

        Provider.of<app.AuthProvider>(context, listen: false).login(user);
        print('User logged in with role: ${user.role}');

        if (mounted) {
          // Force a rebuild of the Wrapper by using a slight delay
          await Future.delayed(const Duration(milliseconds: 100));
          print('Navigating to Wrapper with user role: ${user.role}');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Wrapper()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enter the 6-digit code sent to your phone'),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: const InputDecoration(
                  counterText: "",
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}