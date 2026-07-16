import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'new_password_screen.dart';

class OTPResetScreen extends StatefulWidget {
  final String email;

  const OTPResetScreen({super.key, required this.email});

  @override
  State<OTPResetScreen> createState() => _OTPResetScreenState();
}

class _OTPResetScreenState extends State<OTPResetScreen> {
  final List<TextEditingController> _otp =
  List.generate(6, (_) => TextEditingController());

  bool _verifying = false;

  Future<void> _verify() async {
    final code = _otp.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل 6 أرقام صحيحة")),
      );
      return;
    }

    setState(() => _verifying = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection("passwordOtps")
          .where("email", isEqualTo: widget.email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) throw "لا يوجد رمز مسجل";

      final data = query.docs.first.data();

      if (data["code"] != code) throw "الرمز غير صحيح";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ $e")));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Widget _otpBox(int i) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _otp[i],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        decoration: const InputDecoration(counterText: ""),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter OTP",
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, _otpBox),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifying ? null : _verify,
              child: _verifying
                  ? const CircularProgressIndicator()
                  : const Text("تأكيد"),
            )
          ],
        ),
      ),
    );
  }
}
