import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'admin_panel/screens/admin_login_screen.dart';
import 'admin_panel/theme/admin_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set translucent status bar styling for immersive look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const SeatAndSetAdminApp());
}

class SeatAndSetAdminApp extends StatelessWidget {
  const SeatAndSetAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat and Set • Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AdminColors.bgDark,
        colorSchemeSeed: AdminColors.primaryButton,
        fontFamily: 'Roboto',
      ),
      home: const AdminLoginScreen(),
    );
  }
}
