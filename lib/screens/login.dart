import 'package:flutter/material.dart';
import 'register.dart'; // Đảm bảo file này tồn tại
import '../services/auth_service.dart'; // Đảm bảo file này tồn tại
import 'dashboard.dart'; // Đảm bảo file này tồn tại

// Định nghĩa một hằng số cho breakpoint (ngưỡng chuyển đổi)
const double kDesktopBreakpoint = 600;

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    // Logic đăng nhập của bạn
    final res = await widget.authService.login(
      emailController.text,
      passwordController.text,
    );
    if (res['success']) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminScreen(authService: widget.authService),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'])));
      }
    }
  }

  // Hàm xây dựng TextField có box shadow
  Widget buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // --- WIDGETS CHỨC NĂNG CƠ BẢN ---

  // Hàm mới để xây dựng nội dung Form (phần LOG IN)
  Widget _buildLoginFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "LOG IN",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        buildTextField(
          controller: emailController,
          icon: Icons.person,
          hint: 'Username or Email',
        ),
        const SizedBox(height: 15),
        buildTextField(
          controller: passwordController,
          icon: Icons.lock,
          hint: 'Password',
          obscure: true,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You still don't have an account? "),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RegisterScreen(authService: widget.authService),
                  ),
                );
              },
              child: const Text(
                "Register",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE082), // Màu vàng của bạn
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size.fromHeight(50),
              elevation: 3,
            ),
            child: const Text(
              "Log In",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm mới để xây dựng phần Avatar (cho Mobile)
  Widget _buildMobileAvatar() {
    return Container(
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
    );
  }

  // --- BỐ CỤC (RESPONSIVE) ---

  // Bố cục Mobile (Ảnh 1)
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipPath(
                clipper: LowerHalfCircleClipper(),
                child: Container(
                  height: 200, // ĐIỀU CHỈNH: Giảm chiều cao container màu vàng (kéo nó xuống)
                  color: const Color(0xFFFFE082), 
                ),
              ),
              Positioned(
                // ĐIỀU CHỈNH: Đẩy Avatar lên cao hơn (giảm khoảng cách âm)
                bottom: -20, 
                child: _buildMobileAvatar(),
              ),
            ],
          ),
          const SizedBox(height: 80), // Đủ chỗ cho avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildLoginFormContent(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Bố cục Desktop/Web (Ảnh 2)
  Widget _buildDesktopLayout() {
    // Chiều rộng tối đa của hộp đăng nhập
    const double maxBoxWidth = 800;

    return Center(
      child: Container(
        width: maxBoxWidth,
        height: 500, // Chiều cao cố định hoặc linh hoạt
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cột bên trái: Avatar và Background (Màu Vàng Xanh)
            Expanded(
              flex: 4, // Tỉ lệ 4/10
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE082), // Màu Vàng Xanh như Ảnh 2
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4), // Viền trắng
                    ),
                    child: Container(
                      width: 150, // Avatar lớn hơn
                      height: 150,
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
              ),
            ),

            // Cột bên phải: Form Đăng nhập
            Expanded(
              flex: 6, // Tỉ lệ 6/10
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: SingleChildScrollView(
                  child: _buildLoginFormContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ĐIỀU CHỈNH: Đổi màu nền thành trắng
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > kDesktopBreakpoint) {
            // Màn hình lớn (Desktop/Web)
            return _buildDesktopLayout();
          } else {
            // Màn hình nhỏ (Mobile)
            return _buildMobileLayout();
          }
        },
      ),
    );
  }
}

// --- CLIPPER ĐÃ SỬA ĐỔI ---
class LowerHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // ĐIỀU CHỈNH: Hạ điểm bắt đầu của đường cong (tăng giá trị trừ đi)
    path.lineTo(0, size.height - 100); 
    
    // ĐIỀU CHỈNH: Điều chỉnh đỉnh đường cong để tạo cảm giác tròn và cân đối với avatar
    path.quadraticBezierTo(
      size.width / 2, 
      size.height + 40, // Đỉnh đường cong (cũng điều khiển độ sâu)
      size.width, 
      size.height - 100, // Hạ điểm kết thúc của đường cong
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}