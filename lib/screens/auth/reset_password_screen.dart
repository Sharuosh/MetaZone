import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String oobCode;

  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  double _strength = 0;
  bool _showPass = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _checkPassword(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.3;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.2;
    if (RegExp(r'[!@#\$&*~]').hasMatch(value)) strength += 0.2;

    setState(() => _strength = strength);
  }

  Color _getStrengthColor() {
    if (_strength <= 0.3) return Colors.red;
    if (_strength <= 0.6) return Colors.orange;
    return Colors.greenAccent;
  }

  Future<void> _resetPassword() async {
    final newPassword = passwordController.text.trim();

    if (newPassword.isEmpty || _strength < 0.6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمة المرور ضعيفة — اجعلها أقوى"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تغيير كلمة المرور بنجاح"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "حدث خطأ"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            right: -50,
            child: Container(
              width: 220,
              height: 220,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 95),

                        const SizedBox(height: 12),

                        Text(
                          "Reset Your Password",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 19,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: passwordController,
                          onChanged: _checkPassword,
                          obscureText: !_showPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "New Password",
                            labelStyle:
                            const TextStyle(color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () =>
                                  setState(() => _showPass = !_showPass),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.cyanAccent.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.cyanAccent, width: 1.6),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// مؤشر القوة
                        LinearProgressIndicator(
                          value: _strength,
                          minHeight: 6,
                          color: _getStrengthColor(),
                          backgroundColor: Colors.white12,
                        ),

                        const SizedBox(height: 22),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.6),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                                : const Text(
                              "Update Password",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
