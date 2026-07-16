import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  bool _showPass = false;
  bool _isLoading = false;
  bool _emailNotVerified = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtl.text.trim(),
        password: _passwordCtl.text.trim(),
      );

      final user = cred.user!;
      await user.reload();

      /// ⛔ فحص إذا الحساب معطّل من Firestore
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists && (doc.data()?["disabled"] == true)) {
        await FirebaseAuth.instance.signOut();
        throw Exception("تم تعطيل هذا الحساب");
      }

      /// ❌ تم إلغاء التحقق بالبريد مؤقتًا (يمكن إرجاعه لاحقًا بسهولة)
      /*
      if (!user.emailVerified) {
        _emailNotVerified = true;
        await user.sendEmailVerification();
        throw Exception("قم بتفعيل بريدك الإلكتروني أولاً");
      }
      */

      /// 🕓 تحديث آخر تسجيل دخول
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"lastLogin": FieldValue.serverTimestamp()});

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "حدث خطأ في تسجيل الدخول";

      switch (e.code) {
        case "user-not-found":
          msg = "لا يوجد حساب بهذا البريد";
          break;
        case "wrong-password":
          msg = "كلمة المرور غير صحيحة";
          break;
        case "invalid-email":
          msg = "البريد غير صالح";
          break;
        case "too-many-requests":
          msg = "محاولات كثيرة — حاول لاحقًا";
          break;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اكتب بريدك أولًا")),
      );
      return;
    }

    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailCtl.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال رابط إعادة كلمة المرور")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌙 خلفية ليلية داكنة
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

          /// ✨ توهج نيون
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00FFFF),
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
                    padding: const EdgeInsets.all(22),
                    width: 420,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 95),

                          const SizedBox(height: 10),

                          Text(
                            'Welcome back to Meta Zone',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// EMAIL
                          TextFormField(
                            controller: _emailCtl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "البريد الإلكتروني",
                              labelStyle:
                              const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.cyanAccent,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                  Colors.cyanAccent.withOpacity(0.35),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.cyanAccent,
                                  width: 1.6,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "اكتب البريد الإلكتروني";
                              }
                              if (!v.contains("@")) {
                                return "بريد غير صالح";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          /// PASSWORD
                          TextFormField(
                            controller: _passwordCtl,
                            obscureText: !_showPass,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "كلمة المرور",
                              labelStyle:
                              const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.cyanAccent,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    setState(() => _showPass = !_showPass),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                  Colors.cyanAccent.withOpacity(0.35),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.cyanAccent,
                                  width: 1.6,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty
                                ? "اكتب كلمة المرور"
                                : null,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                );
                              },

                              child: const Text(
                                "نسيت كلمة المرور؟",
                                style: TextStyle(color: Colors.cyanAccent),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// LOGIN BUTTON
                          AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 300),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                              _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                minimumSize:
                                const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                  color: Colors.black)
                                  : const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "ليس لديك حساب؟ قم بإنشاء حساب جديد",
                              style: TextStyle(
                                  color: Colors.cyanAccent),
                            ),
                          ),
                        ],
                      ),
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
