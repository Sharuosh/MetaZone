import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }


  bool _validateEmail(String email) {
    return RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$",
    ).hasMatch(email);
  }

  int _passwordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;
    return strength;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تأكد من البيانات والموافقة على الشروط')),
      );
      return;
    }

    if (_passwordCtl.text != _confirmCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمات المرور غير متطابقة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    UserCredential? cred;
    final username = _usernameCtl.text.trim().toLowerCase();
    final email = _emailCtl.text.trim().toLowerCase();
// ✅ VALIDATE USERNAME FORMAT
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "اسم المستخدم لازم يكون 3–20 حرف (a-z, 0-9, _ فقط)",
          ),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1️⃣ إنشاء حساب Auth (Firebase بيمنع تكرار الإيميل تلقائيًا)
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordCtl.text.trim(),
      );

      final user = cred.user!;

      // 2️⃣ حجز اسم المستخدم ATOMIC
      final usernameRef =
      FirebaseFirestore.instance.collection("usernames").doc(username);

      await usernameRef.set({
        "userId": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 3️⃣ حفظ بيانات المستخدم
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "username": username,
        "email": email,
        "disabled": false,
        "createdAt": FieldValue.serverTimestamp(),
        "avatar":
        "https://ui-avatars.com/api/?name=$username&background=0D8ABC&color=fff",
      });

      // 4️⃣ تفعيل البريد
      await user.sendEmailVerification();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(userId: user.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "خطأ في التسجيل";

      if (e.code == "email-already-in-use") {
        msg = "البريد الإلكتروني مستخدم بالفعل";
      } else if (e.code == "weak-password") {
        msg = "كلمة المرور ضعيفة";
      } else if (e.code == "invalid-email") {
        msg = "البريد الإلكتروني غير صالح";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } on FirebaseException catch (e) {
      // لو الـ username اتحجز وفشل أي حاجة بعده
      if (cred?.user != null) {
        await FirebaseFirestore.instance
            .collection("usernames")
            .doc(username)
            .delete()
            .catchError((_) {});
        await cred!.user!.delete();
      }

      if (e.code == "already-exists") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("اسم المستخدم موجود بالفعل")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("خطأ في قاعدة البيانات")),
        );
      }
    }
    catch (_) {
      if (cred?.user != null) {
        await cred!.user!.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ غير متوقع")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Widget _buildStrengthBar() {
    final s = _passwordStrength(_passwordCtl.text);

    Color c = Colors.red;
    if (s == 2) c = Colors.orange;
    if (s == 3) c = Colors.yellow;
    if (s == 4) c = Colors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: s / 4,
        child: Container(
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController ctl,
    bool obscure = false,
    bool toggle = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        suffixIcon: toggle
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: onToggle,
        )
            : null,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyanAccent, width: 1.6),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      validator:
      validator ?? (v) => v == null || v.isEmpty ? "$label مطلوب" : null,
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

          /// المحتوى
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset("assets/images/logo.png", height: 95),

                          const SizedBox(height: 12),

                          Text(
                            "Create Your Meta Zone Account",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          _buildInput(
                            label: "اسم المستخدم",
                            icon: Icons.person,
                            ctl: _usernameCtl,
                          ),

                          const SizedBox(height: 10),

                          _buildInput(
                            label: "البريد الإلكتروني",
                            icon: Icons.email,
                            ctl: _emailCtl,
                            validator: (v) => v == null || !_validateEmail(v)
                                ? "بريد غير صحيح"
                                : null,
                          ),

                          const SizedBox(height: 10),

                          _buildInput(
                            label: "كلمة المرور",
                            icon: Icons.lock_outline,
                            ctl: _passwordCtl,
                            obscure: !_showPass,
                            toggle: true,
                            onToggle: () =>
                                setState(() => _showPass = !_showPass),
                          ),

                          const SizedBox(height: 6),

                          _buildStrengthBar(),

                          const SizedBox(height: 10),

                          _buildInput(
                            label: "تأكيد كلمة المرور",
                            icon: Icons.lock,
                            ctl: _confirmCtl,
                            obscure: !_showConfirm,
                            toggle: true,
                            onToggle: () =>
                                setState(() => _showConfirm = !_showConfirm),
                          ),

                          Row(
                            children: [
                              Checkbox(
                                value: _agreeTerms,
                                onChanged: (v) =>
                                    setState(() => _agreeTerms = v!),
                                activeColor: Colors.cyanAccent,
                              ),
                              const Text(
                                "أوافق على الشروط والأحكام",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                                : const Text(
                              "تسجيل",
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
          ),
        ],
      ),
    );
  }
}
