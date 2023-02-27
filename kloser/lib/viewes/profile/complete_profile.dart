import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController bio = TextEditingController();
  File? _image;
  String? _url = "";
  bool isLoading = false;
  bool isImageUploadComplete = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
            "${AppLocale.of(context)!.translate("complete_your_profile")}"),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: fullName,
                              decoration: InputDecoration(
                                  hintText:
                                      "${AppLocale.of(context)!.translate("full_name")}",
                                  labelText:
                                      "${AppLocale.of(context)!.translate("enter_full_name")}"),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocale.of(context)!
                                      .translate("field_must_not_be_empty");
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: userName,
                              decoration: InputDecoration(
                                  hintText:
                                      "${AppLocale.of(context)!.translate("user_name")}",
                                  labelText:
                                      "${AppLocale.of(context)!.translate("enter_user_name")}"),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocale.of(context)!
                                      .translate("field_must_not_be_empty");
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: CircleAvatar(
                            backgroundImage:
                                _image == null ? null : FileImage(_image!),
                            child: IconButton(
                              onPressed: () {
                                uploadImage();
                              },
                              icon: const Icon(
                                CupertinoIcons.cloud_upload_fill,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: bio,
                    maxLines: 4,
                    decoration: InputDecoration(
                        hintText: "${AppLocale.of(context)!.translate("bio")}",
                        labelText:
                            "${AppLocale.of(context)!.translate("enter_bio")}",
                        alignLabelWithHint: true),
                  ),
                  const SizedBox(
                    height: 400,
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)))),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_formKey.currentState!.validate()) {
                              await addUser();
                              if (isImageUploadComplete) {
                                // ignore: use_build_context_synchronously
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const HomePage();
                                }), (route) => false);
                              }
                            }
                          }
                        },
                        child: Text(
                            "${AppLocale.of(context)!.translate("create_account")}")),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> addUser() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    Map<String, dynamic> data = {
      'id': FirebaseAuth.instance.currentUser!.uid.toString(),
      'full_name': fullName.text,
      'username': userName.text,
      'bio': bio.text,
      'profile_image_url': _url
    };
    return users
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .set(data)
        .then((vlue) async {
      debugPrint("User Added");
      setState(() {
        isLoading = false;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'uuid', FirebaseAuth.instance.currentUser!.uid.toString());
      // ignore: invalid_return_type_for_catch_error
    }).catchError((error) => debugPrint("Failed to add user: $error"));
  }

  uploadImage() async {
    setState(() {
      isLoading = true;
      isImageUploadComplete = false;
    });
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image!.path);
    });
    if (image != null) {
      String? url;
      try {
        UploadTask task = FirebaseStorage.instance
            .ref("images/${image.name}")
            .putFile(File(image.path));
        task.whenComplete(() async {
          url = await FirebaseStorage.instance
              .ref()
              .child("images/${image.name}")
              .getDownloadURL();
          setState(() {
            _url = url;
            isLoading = false;
            isImageUploadComplete = true;
          });
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
