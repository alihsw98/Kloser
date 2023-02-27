import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kloser/settings/color.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/auth/login.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kloser/viewes/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kloser',
      theme: appTheme,
      routes: {
        '/sign_in': (context) => const LoginPage(),
        '/home_page': ((context) => const HomePage())
      },
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: const Locale("ean"),
      localizationsDelegates: const [
        AppLocale.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (currentLocale, supportedLocales) {
        for (Locale locale in supportedLocales) {
          if (locale.languageCode == currentLocale!.languageCode) {
            return locale;
          }
        }
        return supportedLocales.first;
      },
      home: Scaffold(body: isuserloggedin()),
    );
  }
}

Widget isuserloggedin() {
  if (FirebaseAuth.instance.currentUser != null) {
    return const HomePage();
  } else {
    return const LoginPage();
  }
}

ThemeData appTheme = ThemeData(
  primarySwatch: AppColors.getMaterialColor(AppColors.primaryColor),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.never,
    isDense: true,
    contentPadding: const EdgeInsets.all(10),
    labelStyle: const TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: AppColors.primaryColor.withOpacity(.37),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: AppColors.grey,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: AppColors.primaryColor,
        width: 1,
      ),
    ),
  ),
);
