import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login.dart';
import 'firebase_options.dart'; // import file config Firebase web

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase theo platform
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userService = UserService();
  final authService = AuthService(userService: userService);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(authService: authService),
    );
  }
}
