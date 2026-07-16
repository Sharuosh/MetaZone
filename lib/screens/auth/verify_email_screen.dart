import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sent = false;
  bool _checking = false;

  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.sendEmailVerification();
    setState(() => _sent = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال رسالة التفعيل إلى بريدك")),
    );
  }

  Future<void> _refresh() async {
    setState(() => _checking = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يزال البريد غير مفعّل")),
      );
    }

    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 خلفية ليلية
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

          /// 💡 توهج نيون
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 230,
              height: 230,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent,
              ),
              foregroundDecoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    blurRadius: 160,
                  ),
                ],
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
                    width: 430,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 95),

                        const SizedBox(height: 12),

                        const Text(
                          "فعّل بريدك الإلكتروني",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "تم إرسال رابط التفعيل إلى:",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          user?.email ?? "",
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton(
                          onPressed: _sent ? null : _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: Text(
                            _sent
                                ? "✔ تم إرسال الإيميل"
                                : "إعادة إرسال التفعيل",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _checking
                            ? const CircularProgressIndicator(
                            color: Colors.cyanAccent)
                            : ElevatedButton(
                          onPressed: _refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize:
                            const Size.fromHeight(50),
                          ),
                          child: const Text(
                            "تم التفعيل — تحديث",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text(
                            "تبديل حساب",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        )
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
