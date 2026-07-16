import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String userId;

  const OTPScreen({super.key, required this.userId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otp =
  List.generate(6, (_) => TextEditingController());

  int _seconds = 60;
  Timer? _timer;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// توليد كود جديد
  String _generateOtp() {
    final rnd = Random();
    return (rnd.nextInt(900000) + 100000).toString();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    for (var c in _otp) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  /// ⛔️ التحقق من الكود
  Future<void> _verifyCode() async {
    final code = _otp.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل 6 أرقام صحيحة")),
      );
      return;
    }

    setState(() => _verifying = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection("emailOtps")
          .doc(widget.userId);

      final doc = await ref.get();

      if (!doc.exists) throw "لا يوجد رمز مُسجل";

      final data = doc.data()!;
      final savedCode = data["code"];
      final attempts = data["attempts"] ?? 0;
      final expiresAt = (data["expiresAt"] as Timestamp).toDate();

      if (attempts >= 5) throw "عدد المحاولات كثير — حاول لاحقًا";

      if (DateTime.now().isAfter(expiresAt)) {
        throw "انتهت صلاحية الرمز — اطلب رمزًا جديدًا";
      }

      await ref.update({"attempts": attempts + 1});

      if (code != savedCode) throw "الرمز غير صحيح";

      /// 🎉 تم التفعيل
      await ref.update({"verified": true});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({"emailVerified": true});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✔ تم تفعيل الحساب بنجاح"),
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
      if (mounted) setState(() => _verifying = false);
    }
  }

  /// 🔁 إعادة إرسال OTP جديد
  Future<void> _resendCode() async {
    if (_seconds > 0) return;

    setState(() => _resending = true);

    try {
      final newOtp = _generateOtp();

      await FirebaseFirestore.instance
          .collection("emailOtps")
          .doc(widget.userId)
          .set({
        "code": newOtp,
        "verified": false,
        "attempts": 0,
        "createdAt": FieldValue.serverTimestamp(),
        "expiresAt": DateTime.now().add(const Duration(minutes: 5)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✔ كود جديد: $newOtp"),
          backgroundColor: Colors.blueAccent,
        ),
      );

      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
    } finally {
      setState(() => _resending = false);
    }
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _otp[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, color: Colors.white),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.cyanAccent.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.cyanAccent,
              width: 1.6,
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// الخلفية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF020617),
                  Color(0xFF050827),
                  Color(0xFF0A103F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/logo.png", height: 90),

                        const SizedBox(height: 12),

                        Text(
                          "Verification Code",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "ادخل الرمز المكون من 6 أرقام",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, _otpBox),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          _seconds > 0
                              ? "إعادة الإرسال خلال $_seconds ثانية"
                              : "يمكنك طلب رمز جديد الآن",
                          style: const TextStyle(color: Colors.white),
                        ),

                        TextButton(
                          onPressed: _seconds == 0 ? _resendCode : null,
                          child: _resending
                              ? const CircularProgressIndicator(
                              color: Colors.cyanAccent)
                              : const Text(
                            "إعادة إرسال الرمز",
                            style:
                            TextStyle(color: Colors.cyanAccent),
                          ),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: _verifying ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: _verifying
                              ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                              : const Text(
                            "تأكيد",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
