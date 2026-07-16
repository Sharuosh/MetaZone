import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {

  final otpController = TextEditingController();

  bool sending = false;
  bool verifying = false;

  String? otpCode;

  int seconds = 60;
  Timer? timer;

  /// توليد OTP
  String _generateOtp() {
    final rnd = Random();
    return (rnd.nextInt(900000) + 100000).toString();
  }

  @override
  void initState() {
    super.initState();
    _sendOtp();
    _startTimer();
  }

  void _startTimer() {
    seconds = 60;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) t.cancel();
      setState(() => seconds--);
    });
  }

  Future<void> _sendOtp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => sending = true);

    try {
      otpCode = _generateOtp();

      await FirebaseFirestore.instance
          .collection("emailOtps")
          .doc(user.uid)
          .set({
        "code": otpCode,
        "verified": false,
        "createdAt": FieldValue.serverTimestamp(),
        "expiresAt": DateTime.now().add(const Duration(minutes: 5)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✔ كود التفعيل: $otpCode"),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      setState(() => sending = false);
    }
  }

  Future<void> _verify() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => verifying = true);

    final code = otpController.text.trim();

    try {
      final doc = await FirebaseFirestore.instance
          .collection("emailOtps")
          .doc(user.uid)
          .get();

      if (!doc.exists) throw "لا يوجد رمز";

      final data = doc.data()!;
      final saved = data["code"];

      if (code != saved) throw "الرمز غير صحيح";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"emailVerified": true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تفعيل الحساب ✔"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ $e")));
    } finally {
      setState(() => verifying = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "تفعيل الحساب",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                user?.email ?? "",
                style: const TextStyle(color: Colors.cyanAccent),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "ادخل كود التفعيل",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: verifying ? null : _verify,
                child: verifying
                    ? const CircularProgressIndicator()
                    : const Text("تفعيل"),
              ),

              TextButton(
                onPressed: seconds == 0 ? _sendOtp : null,
                child: Text(
                  seconds == 0
                      ? "إعادة إرسال كود"
                      : "يمكنك إعادة الإرسال بعد $seconds ثانية",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
