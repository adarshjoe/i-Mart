import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Import EasyLoading
import 'package:get/get.dart';
import 'package:i_mart/controllers/banner_controller.dart';
import 'package:i_mart/controllers/category_controller.dart';
import 'package:i_mart/views/buyers/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import for ProviderScope

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization for Web and other platforms
  await _initializeFirebase();

  // Wrapping the app with ProviderScope to use Riverpod
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

// Function to handle Firebase initialization
Future<void> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCuHoQ60vK0eP0r2GLH5izPUe7sZP41a6o",
          appId: "1:265282914280:web:a23b279191e13236b4865d",
          messagingSenderId: "265282914280",
          projectId: "imart-bf7d0",
          storageBucket: "imart-bf7d0.appspot.com",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iMart App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home:  LoginScreen(),
      initialBinding: BindingsBuilder(() {
        // Initialize controllers with GetX
        Get.put<CategoryController>(CategoryController());
        Get.put<BannerController>(BannerController());
      }),
      builder: EasyLoading.init(), // Initialize EasyLoading here
    );
  }
}
