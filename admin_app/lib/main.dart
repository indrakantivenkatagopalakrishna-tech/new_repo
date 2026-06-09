import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  final apiService = ApiService();
  await apiService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF04020E);
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF0D060);

    return MaterialApp(
      title: 'Temple Pooja Booking Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: goldPrimary,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: goldPrimary,
          secondary: goldLight,
          background: backgroundColor,
        ),
      ),
      home: ApiService().isAuthenticated ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
