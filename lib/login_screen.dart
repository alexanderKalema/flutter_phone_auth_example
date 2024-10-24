import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _codeController = TextEditingController();
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Phone Number",
                ),
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Password",
                ),
                obscureText: true,
                controller: _passController,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    final mobile = _phoneController.text.trim();
                    registerUser(mobile, context);
                  },
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential _credential) {
          _auth.signInWithCredential(_credential).then((UserCredential result) {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => HomeScreen(user: result.user,)
            ));
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          // Show dialog to take input from the user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                AlertDialog(
                  title: const Text("Enter SMS Code"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () async {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        String smsCode = _codeController.text.trim();
                        PhoneAuthCredential credential = PhoneAuthProvider
                            .credential(
                          verificationId: verificationId,
                          smsCode: smsCode,
                        );
                        try {
                          UserCredential result = await auth
                              .signInWithCredential(credential);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                HomeScreen(user: result.user!)),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text("Done"),
                    )
                  ],
                ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timeout");
        }
    );
  }
}
