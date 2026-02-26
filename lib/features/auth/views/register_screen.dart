import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/auth_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all required fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Default role for the app
  String _selectedRole = 'student'; 
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A90E2);
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header ────────────────────────────────────────────
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join Bacolod Boarding Guard today',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                  ),
                  const SizedBox(height: 30),

                  // ─── Role Selection ────────────────────────────────────
                  const Text(
                    "I am registering as a:",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildRoleOption('student', Icons.school_outlined, 'Student'),
                      const SizedBox(width: 12),
                      _buildRoleOption('landlord', Icons.home_work_outlined, 'Landlord'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Name Fields ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AuthFormField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          hintText: 'Juan',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthFormField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          hintText: 'Dela Cruz',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Contact & Auth Fields ─────────────────────────────
                  AuthFormField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    hintText: '09123456789',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android_outlined,
                    validator: (v) => v!.length < 11 ? 'Enter valid phone number' : null,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'juan@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: !_isPasswordVisible,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    obscureText: !_isConfirmPasswordVisible,
                    prefixIcon: Icons.lock_reset_outlined,
                    validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                  ),

                  // ─── Sign Up Button ────────────────────────────────────
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authViewModel.isLoading 
                      ? null 
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Close the keyboard
                            FocusScope.of(context).unfocus();

                            final success = await authViewModel.register(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              role: _selectedRole,
                            );

                            // Check if the widget is still mounted before showing Snackbars or Navigating
                            if (!context.mounted) return;

                            if (success) {
                              // 🔥 Added Success Message!
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registration successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Pop back to login screen so they can log in
                              Navigator.pop(context);
                            } else {
                              // Show Error Message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authViewModel.errorMessage ?? 'Registration failed. Check console.'),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 4), // Longer duration to read error
                                ),
                              );
                            }
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: authViewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Sign up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  
                  // ─── Login Redirect ────────────────────────────────────
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?', style: TextStyle(color: Color(0xFF718096))),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Log in', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for Role selection
  Widget _buildRoleOption(String role, IconData icon, String label) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A90E2).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF718096)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF718096),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}