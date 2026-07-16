import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'otp_reset_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isSending = false;

  /// توليد OTP
  String _generateOtp() {
    final rnd = Random();
    return (rnd.nextInt(900000) + 100000).toString();
  }

  Future<void> _sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اكتب بريد إلكتروني صحيح")),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      /// التأكد أن المستخدم موجود في النظام
      final q = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        throw Exception("هذا البريد غير مسجل لدينا");
      }

      /// توليد OTP
      final otp = _generateOtp();

      /// ⚠️ المهم هنا:
      /// 1) تغيير expiresAt إلى expireTime لتجنب حذف Firestore التلقائي
      /// 2) استخدام UTC لمنع أخطاء الوقت
      await FirebaseFirestore.instance
          .collection("passwordResetOtps")
          .doc(email) // ← نخزن باستخدام الإيميل مباشرة
          .set({
        "otp": otp,
        "email": email,
        "verified": false,
        "attempts": 0,
        "createdAt": FieldValue.serverTimestamp(),
        "expireTime": DateTime.now()
            .toUtc()
            .add(const Duration(minutes: 5)),
      });

      /// 👀 عرض الكود للمستخدم داخل التطبيق (نظام تجريبي بدون Email)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✔ كود إعادة التعيين: $otp"),
          backgroundColor: Colors.green,
        ),
      );

      /// 👉 الانتقال إلى شاشة إدخال OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPResetScreen(email: email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/logo.png", height: 95),

                        const SizedBox(height: 10),

                        Text(
                          "Reset Password",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "أدخل بريدك الإلكتروني لاستلام رمز إعادة التعيين",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "البريد الإلكتروني",
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.cyanAccent,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.cyanAccent.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.cyanAccent,
                                width: 1.6,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(18)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        ElevatedButton(
                          onPressed: _isSending ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: _isSending
                              ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                              : const Text(
                            "إرسال رمز التحقق",
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
          ),
        ],
      ),
    );
  }
}
