import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: wire up real authentication (Firebase Auth, etc.)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _handleForgotPassword() {
    // TODO: navigate to forgot password flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              //Background gradient
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppGradients.bgGradient,
                ),
                child: const Expanded (
                  child: Text("Login Page"),
                ),
              ),
              // Overlay
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(42),
                        bottomRight: Radius.circular(42),
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 6,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.2),
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset('assets/images/upc-logo.png', width: 240, height: 240),
                                ),
                              ),
                            ),
                            Image.asset('assets/images/upc-logo.png', width: 240, height: 240),
                          ],
                        ),
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return AppGradients.logotypeGradient.createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'UPC CONNECT',
                            style: AppTextStyles.heading1,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              fillColor: AppColors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                                      
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              fillColor: AppColors.white,
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                                      
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                                      
                          const SizedBox(height: 16),
                                      
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Log In', style: AppTextStyles.button),
                          ),
                                      
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
              ),
              ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
