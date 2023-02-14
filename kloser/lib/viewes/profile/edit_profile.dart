import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
            "${AppLocale.of(context)!.translate("complete_your_profile")}"),
        automaticallyImplyLeading: false,
      ),
      body: Form(
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
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                Expanded(
                    child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4, color: AppColors.primaryColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: AppColors.primaryColor.withOpacity(.1)),
                          ],
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  "https://firebasestorage.googleapis.com/v0/b/kloser-7aa4c.appspot.com/o/profileImages?alt=media&token=b3c657d6-3d7a-47ea-a5e0-3945783132a4"))),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 140,
                      child: GestureDetector(
                        onTap: () {
                          uploadImage();
                        },
                        child: Icon(
                          Icons.add_a_photo,
                          color: AppColors.primaryColor.withOpacity(.87),
                        ),
                      ),
                    )
                  ],
                )),
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
                  labelText: "${AppLocale.of(context)!.translate("enter_bio")}",
                  alignLabelWithHint: true),
            ),
            const SizedBox(
              height: 400,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)))),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_formKey.currentState!.validate()) {
                        addUser();
                        // // ignore: use_build_context_synchronously
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return const EditProfilePage();
                        // }));
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

  Future<void> addUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .add({
          'id': FirebaseAuth.instance.currentUser!.uid.toString(),
          'full_name': fullName.text,
          'username': userName.text,
          'bio': bio.text
        })
        .then((value) => debugPrint("User Added"))
        .catchError((error) => debugPrint("Failed to add user: $error"));
  }

  uploadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    FirebaseStorage.instance.ref("profileImages").putFile(File(image!.path));
  }
}
