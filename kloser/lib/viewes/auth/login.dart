// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kloser/viewes/auth/signup.dart';

import '../../settings/locale/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(
              height: 80,
            ),
            const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 80,
            ),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                  hintText: "${AppLocale.of(context)!.translate("email")}",
                  labelText:
                      "${AppLocale.of(context)!.translate("enter_email")}"),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocale.of(context)!
                      .translate("field_must_not_be_empty");
                }
                if (!isEmailValid(value)) {
                  return AppLocale.of(context)!
                      .translate("enter_a_valid_email");
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: password,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  hintText: "${AppLocale.of(context)!.translate("password")}",
                  labelText:
                      "${AppLocale.of(context)!.translate("enter_password")}"),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocale.of(context)!
                      .translate("field_must_not_be_empty");
                }
                if (value.length < 5) {
                  return AppLocale.of(context)!.translate("short_password");
                }
                return null;
              },
            ),
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)))),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // ignore: unused_local_variable
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: email.text, password: password.text);
                        Navigator.pushNamed(context, '/home_page');
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title:
                                '${AppLocale.of(context)!.translate("error")}',
                            desc:
                                '${AppLocale.of(context)!.translate("No user found for that email.")}',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                          debugPrint('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title:
                                '${AppLocale.of(context)!.translate("error")}',
                            desc:
                                '${AppLocale.of(context)!.translate("'Wrong password provided for that user.'")}',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                          debugPrint('Wrong password provided for that user.');
                        }
                      }
                    }
                  },
                  child: Text("${AppLocale.of(context)!.translate("log_in")}")),
            ),
            const SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "${AppLocale.of(context)!.translate("already_have_an_account")}"),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SignUpPage();
                      }));
                    },
                    child: Text(
                        "${AppLocale.of(context)!.translate("create_account")}"))
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isEmailValid(String? email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email!);
  }
}
