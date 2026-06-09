import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = ApiService().baseUrl;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Save Base URL
    await ApiService().setBaseUrl(_apiUrlController.text.trim());

    // Perform Login
    final success = await ApiService().login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Invalid credentials or API server unreachable.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cosmic design guidelines
    const backgroundColor = Color(0xFF04020E);
    const cardColor = Color(0xFF080415);
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF0D060);
    const textStarlight = Colors.white;
    const textMuted = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Icon
              const Icon(
                Icons.wb_sunny_outlined,
                size: 80,
                color: goldPrimary,
              ),
              const SizedBox(height: 16),
              // App Name
              const Text(
                "VAGDEVI JYOTISHALAYAM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: goldLight,
                  fontFamily: 'serif',
                ),
              ),
              const Text(
                "Admin Control Portal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 40),
              
              // Login Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goldPrimary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: goldPrimary.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textStarlight,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // API Base URL Field
                      TextFormField(
                        controller: _apiUrlController,
                        style: const TextStyle(color: textStarlight),
                        decoration: InputDecoration(
                          labelText: "API Server URL",
                          labelStyle: const TextStyle(color: textMuted),
                          prefixIcon: const Icon(Icons.link, color: goldPrimary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: goldPrimary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: goldPrimary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter backend API URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: textStarlight),
                        decoration: InputDecoration(
                          labelText: "Username",
                          labelStyle: const TextStyle(color: textMuted),
                          prefixIcon: const Icon(Icons.person_outline, color: goldPrimary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: goldPrimary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: goldPrimary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: textStarlight),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: textMuted),
                          prefixIcon: const Icon(Icons.lock_outline, color: goldPrimary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: goldPrimary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: goldPrimary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldPrimary,
                          foregroundColor: backgroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: backgroundColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("LOGIN"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
