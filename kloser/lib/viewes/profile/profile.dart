import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/profile/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var n = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  dynamic userData;
  bool isLoading = true;
  @override
  void initState() {
    getUserData().then((value) {
      setState(() {
        getUserData();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${AppLocale.of(context)!.translate("profile")}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 4),
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFf8fafb)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 75,
                                    height: 75,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: userData['profile_image_url'] != ""
                                          ? Image.network(
                                              userData['profile_image_url'],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "assets/images/no_image.jpg"),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData['full_name'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        userData['username'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.grey),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Icon(
                                      CupertinoIcons.chat_bubble_text_fill,
                                      color: Color(0xFF484860),
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(
                                      CupertinoIcons.person_add_solid,
                                      color: Color(0xFF484860),
                                      size: 30,
                                    ),
                                  ]),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: const [
                                Text(
                                  "1.2M",
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Follower",
                                  style: TextStyle(
                                      color: Color(0xFF484860),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: const [
                                Text(
                                  "98",
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Following",
                                  style: TextStyle(
                                      color: Color(0xFF484860),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: const [
                                Text(
                                  "250",
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Posts",
                                  style: TextStyle(
                                      color: Color(0xFF484860),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const EditProfilePage();
                              }));
                            },
                            child: Text(AppLocale.of(context)!
                                .translate("edit_profile")!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 4,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemCount: 16,
                          itemBuilder: ((context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "assets/images/${n[index]}.jpg",
                                fit: BoxFit.cover,
                              ),
                            );
                          })),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('uuid');

    DocumentReference doc =
        FirebaseFirestore.instance.collection('users').doc(uid);
    var data = await doc.get();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }
}
