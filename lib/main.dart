import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/login_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/cart_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBTW7ZQ7Ph8slJjhYOicnLljAd3bCj_WkE",
        appId: "1:499367369742:android:5fae5cd747cac9edd1305f",
        messagingSenderId: "499367369742",
        projectId: "foody-2004",
        storageBucket: "foody-2004.firebasestorage.app",
      ),
    );

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    
    runApp(FoodyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class FoodyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foody',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: LoginScreen(),
      routes: {
        '/order_details': (context) => const OrderDetailsScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
