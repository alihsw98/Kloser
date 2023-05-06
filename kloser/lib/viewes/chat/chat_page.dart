import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'message.dart';

class Chatpage extends StatefulWidget {
  final String email;
  const Chatpage({super.key, required this.email});
  @override
  ChatpageState createState() => ChatpageState();
}

class ChatpageState extends State<Chatpage> {
  final instance = FirebaseFirestore.instance;
  final TextEditingController message = TextEditingController();
  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();
  final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
      .collection('Messages')
      .orderBy('time')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.email,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.79,
              child: StreamBuilder(
                stream: _messageStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("something is wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController2,
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data!.docs.length,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      QueryDocumentSnapshot qs = snapshot.data!.docs[index];
                      Timestamp t = qs['time'];
                      DateTime d = t.toDate();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: widget.email == qs['email']
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(
                                  qs['email'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        qs['message'],
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${d.hour}:${d.minute}",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              // Messages(
              //   email: widget.email,
              // ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: message,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.primaryColor.withOpacity(.37),
                        hintText:
                            '${AppLocale.of(context)!.translate("message")}',
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) {
                        message.text = value!;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (message.text.isNotEmpty) {
                        instance.collection('Messages').doc().set({
                          'message': message.text.trim(),
                          'time': DateTime.now(),
                          'email': widget.email,
                        });
                        setState(() {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                          scrollController2.animateTo(
                            scrollController2.position.maxScrollExtent,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        });
                        message.clear();
                      }
                    },
                    icon: const Icon(Icons.send_sharp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
