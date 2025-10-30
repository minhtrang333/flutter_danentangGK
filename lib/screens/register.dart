import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// ĐỊNH NGHĨA MÀU VÀNG ĐỒNG BỘ
const Color kPrimaryYellow = Color(0xFFFFE082); // Màu vàng nhạt
const Color kAccentYellow = Color(0xFFC7CD79);  // Màu vàng xanh

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validation (Sửa thông báo lỗi sang Tiếng Anh)
    String? error;

    if (username.isEmpty) {
      error = 'Username cannot be empty';
    } else if (username.length < 3) {
      error = 'Username must be at least 3 characters long';
    } else if (email.isEmpty) {
      error = 'Email cannot be empty';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      error = 'Invalid email format';
    } else if (password.isEmpty) {
      error = 'Password cannot be empty';
    } else if (password.length < 6) {
      error = 'Password must be at least 6 characters long';
    } else if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
    ).hasMatch(password)) {
      error = 'Password must contain at least 1 uppercase, 1 lowercase, and 1 number';
    }

    if (error != null) {
      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    // Thực hiện đăng ký
    final res = await widget.authService.register(
      username,
      email,
      password,
      '',
    );
    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration successful'))); // SỬA: Đăng ký thành công
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double kMobileBreakpoint = 600;
    final isMobile = size.width < kMobileBreakpoint;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryYellow, kAccentYellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isMobile
              ? _buildVerticalLayout(context)
              : _buildCardLayout(context),
        ),
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: _buildRegisterForm(context),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
        ),
        child: _buildRegisterForm(context),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // THAY THẾ ICON BẰNG ẢNH AVATAR
        Container(
          width: 110, 
          height: 110,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 100, 
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/image.png'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),

        // Title
        const Text(
          'Register', // SỬA: Đăng ký
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Username input
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            labelText: 'Username', // SỬA: Username
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryYellow, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Email input
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email),
            labelText: 'Email', // SỬA: Email
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryYellow, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Password input
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            labelText: 'Password', // SỬA: Password
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryYellow, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 25),

        // Register Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: register,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              elevation: 4,
            ),
            child: const Text(
              'Register', // SỬA: Đăng ký
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Back to Login Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: kAccentYellow, width: 2),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text(
              'Back to Login', // SỬA: Quay về đăng nhập
              style: TextStyle(color: kAccentYellow),
            ),
          ),
        ),
      ],
    );
  }
}