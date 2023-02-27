import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullName = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController bio = TextEditingController();
  File? _image;
  String? _url;

  bool isLoading = false;
  bool isImageUploadComplete = true;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text("${AppLocale.of(context)!.translate("edit_profile")}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
                              onPressed: uploadImage,
                              icon: const Icon(
                                CupertinoIcons.cloud_upload_fill,
                                color: AppColors.primaryColor,
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
                              await updateUser();
                              if (isImageUploadComplete) {
                                // ignore: use_build_context_synchronously
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ProfilePage();
                                }));
                              }
                            }
                          }
                        },
                        child: Text(
                            "${AppLocale.of(context)!.translate("edit_profile")}")),
                  ),
                ],
              ),
            ),
    );
  }

  uploadImage() async {
    setState(() {
      isLoading = true;
      isImageUploadComplete = false;
    });
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uuid');

    DocumentReference doc =
        FirebaseFirestore.instance.collection('users').doc(uid);
    await doc.update({
      'id': FirebaseAuth.instance.currentUser!.uid.toString(),
      'full_name': fullName.text,
      'username': userName.text,
      'bio': bio.text,
      'profile_image_url': _url
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uuid');

    DocumentReference doc =
        FirebaseFirestore.instance.collection('users').doc(uid);
    var data = await doc.get();
    setState(() {
      fullName.text = data["full_name"];
      userName.text = data["username"];
      bio.text = data["bio"];
      _url = data["profile_image_url"];
      isLoading = false;
    });
  }
}
