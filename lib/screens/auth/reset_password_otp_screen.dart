import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOTPScreen({super.key, required this.email});

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final TextEditingController controller = TextEditingController();
  bool _loading = false;

  Future<void> verifyOtp() async {
    final code = controller.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل الكود المكون من 6 أرقام")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      /// نفس الكولكشن الذي أنشأناه في ForgotPassword
      final doc = await FirebaseFirestore.instance
          .collection("passwordOtps")
          .doc(widget.email)
          .get();

      if (!doc.exists) {
        throw "لا يوجد طلب إعادة تعيين كلمة المرور";
      }

      final data = doc.data()!;
      final savedOtp = data["code"];
      final expiresAt = (data["expiresAt"] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        throw "انتهت صلاحية الكود — اطلب كود جديد";
      }

      if (savedOtp != code) {
        throw "الكود غير صحيح";
      }

      /// تحديث الحالة إلى verified
      await doc.reference.update({"verified": true});

      /// الانتقال لشاشة إدخال كلمة المرور الجديدة
      Navigator.pushNamed(
        context,
        "/reset",
        arguments: widget.email,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "أدخل رمز التحقق",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "تم إرسال الرمز إلى\n${widget.email}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: controller,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "******",
                          hintStyle: TextStyle(color: Colors.white38),
                          counterText: "",
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: _loading ? null : verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _loading
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
          )
        ],
      ),
    );
  }
}
