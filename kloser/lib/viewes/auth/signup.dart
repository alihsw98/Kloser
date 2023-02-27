import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/auth/login.dart';
import 'package:kloser/viewes/profile/complete_profile.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool _passwordVisible = false;
  UserCredential? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocale.of(context)!.translate("create_account")}"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Form(
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
                        await signUp();
                        if (_user != null) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const CompleteProfilePage();
                          }));
                        }
                      }
                    },
                    child: Text(
                        "${AppLocale.of(context)!.translate("create_account")}")),
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
                          return const LoginPage();
                        }));
                      },
                      child:
                          Text("${AppLocale.of(context)!.translate("log_in")}"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEmailValid(String? email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email!);
  }

  Future<void> signUp() async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      setState(() {
        _user = credential;
      });
      debugPrint("done");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: '${AppLocale.of(context)!.translate("error")}',
          desc: '${AppLocale.of(context)!.translate("weak_password")}',
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        ).show();
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: '${AppLocale.of(context)!.translate("error")}',
          desc: '${AppLocale.of(context)!.translate("email_already_exists")}',
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        ).show();
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
