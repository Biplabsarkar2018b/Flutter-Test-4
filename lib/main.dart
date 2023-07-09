import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test4/constants/color_constants.dart';
import 'package:test4/firebase_options.dart';
import 'package:test4/pages/splash_page.dart';
import 'package:test4/providers/auth_provider.dart';
import 'package:test4/providers/chat_provider.dart';
import 'package:test4/providers/home_provider.dart';
import 'package:test4/providers/setting_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences,));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            firebaseFirestore: this.firebaseFirestore,
            googleSignIn: GoogleSignIn(),
            sharedPreferences: this.sharedPreferences,
          ),
        ),
        Provider<HomeProvider>(
          create: (_)=> HomeProvider(firebaseFirestore: this.firebaseFirestore),
        ),
        Provider<SettingProvider>(
          create: (_) => SettingProvider(
            prefs: this.sharedPreferences,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            sharedPreferences: this.sharedPreferences,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Chat App",
        theme: ThemeData(
          primaryColor: ColorConstants.themeColor,
          primarySwatch: MaterialColor(0xfff5a623, ColorConstants.swatchColor),
        ),
        home: SplashPage(),
      ),
    );
  }
}
