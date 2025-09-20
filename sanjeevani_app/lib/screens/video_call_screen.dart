import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'create_prescription_screen.dart';

class VideoCallScreen extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final bool isDoctor;
  final int doctorIdForPrescription;
  final int patientIdForPrescription;
  final int appointmentIdForPrescription;

  const VideoCallScreen({
    Key? key,
    required this.callID,
    required this.userID,
    required this.userName,
    this.isDoctor = false,
    required this.doctorIdForPrescription,
    required this.patientIdForPrescription,
    required this.appointmentIdForPrescription,
  }) : super(key: key);

  // --- IMPORTANT: PASTE YOUR ZEGOCLOUD KEYS HERE ---
  // You get these from the ZEGOCLOUD console after signing up.
  static const int yourAppID = 447765549; // <-- Replace with your AppID
  static const String yourAppSign = "db486b9b1f0e1b9c55a9392a0fe30583770c6ffe8d9c4165ef7b360a0462aa16"; // <-- Replace with your AppSign

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: yourAppID,
      appSign: yourAppSign,
      userID: userID,
      userName: userName,
      callID: callID,
      // The base config no longer handles events.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      
      // --- THIS IS THE NEW, CORRECTED SYNTAX ---
      // We now provide an 'events' object to handle callbacks.
      events: ZegoUIKitPrebuiltCallEvents(
        // This callback is triggered when the call ends for any reason.
        onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
          // The defaultAction is what ZegoCloud would normally do (e.g., go back).
          // We can choose to run it or run our own custom logic.
          
          if (isDoctor) {
            // If the user is a doctor, we navigate them to the prescription screen.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePrescriptionScreen(
                  patientId: patientIdForPrescription,
                  doctorId: doctorIdForPrescription,
                  appointmentId: appointmentIdForPrescription,
                ),
              ),
            );
          } else {
            // If the user is a patient, we can just run the default action,
            // which will safely take them back to the previous screen.
            defaultAction();
          }
        },
      ),
    );
  }
}

