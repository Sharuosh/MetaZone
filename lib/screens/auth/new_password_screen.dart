import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final pass = TextEditingController();
  bool loading = false;

  Future<void> update() async {
    setState(() => loading = true);

    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: "temporaryPasswordForReset#", // أي باسورد قديم لازم تعرفه؟ لا، سنستخدم authless reset لاحقاً
      );
    } catch (_) {}

    await FirebaseAuth.instance.currentUser!.updatePassword(pass.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تغيير كلمة المرور")),
    );

    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              TextField(
                controller: pass,
                obscureText: true,
              ),

              ElevatedButton(
                  onPressed: loading ? null : update,
                  child: const Text("حفظ")
              )

            ],
          ),
        ),
      ),
    );
  }
}
