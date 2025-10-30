import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'userform.dart';
import 'login.dart';

// --- Khai báo hằng số màu sắc (Đã điều chỉnh để match thiết kế) ---
// Màu vàng/kem nhạt cho header và nền nút Edit
const Color _kPrimaryHeaderColor = Color(0xFFF0E68C); // Khaki
// Màu nền chính của body
const Color _kBackgroundColor = Color(0xFFF9F9F9);
// Màu cho username (vàng cam)
const Color _kUsernameColor = Color(0xFFDAA520); // Goldenrod
// Màu cho nút Add (đen/xanh đậm)
const Color _kAccentColor = Color(0xFFF0E68C);
// Màu viền cho các ô thông tin và search bar
const Color _kCardBorderColor = Color(0xFF424242); // Xám đậm hơn
// Màu nền nút Delete
const Color _kDeleteButtonColor = Color(0xFFEF5350); // Red
// Màu text/icon của nút Edit
const Color _kEditTextColor = Colors.black87; // Đen nhạt

class AdminScreen extends StatefulWidget {
  final AuthService authService;
  const AdminScreen({super.key, required this.authService});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final userService = UserService();
  List<User> users = [];
  String search = '';

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final allUsers = await userService.getAll();
    setState(() {
      users = allUsers;
    });
  }

  void deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa người dùng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kDeleteButtonColor,
              foregroundColor: Colors.white, // Màu chữ/icon trắng
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await userService.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xóa thành công')));
        loadUsers();
      }
    }
  }

  void openForm({User? user}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          user: user,
          onSave: (username, email, password, image) async {
            if (user == null) {
              await widget.authService.register(
                username,
                email,
                password,
                image,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Thêm thành công')));
            } else {
              user.username = username;
              user.email = email;
              if (password.isNotEmpty) {
                user.passwordHash = widget.authService.hashPassword(password);
              }
              user.image = image;
              await userService.update(user);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cập nhật thành công')),
              );
            }
            loadUsers();
          },
        ),
      ),
    );
  }

  // --- Widget Card Người dùng (ĐÃ SỬA VIỀN VÀ NÚT) ---
  Widget _buildUserCard(User u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _kCardBorderColor, width: 2), // VIỀN ĐẬM HƠN
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: u.image.isNotEmpty
                ? MemoryImage(base64Decode(u.image))
                : null,
            child: u.image.isEmpty
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey[400],
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  u.username,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kUsernameColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  u.email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Các nút Edit và Delete (ĐÃ SỬA MÀU VÀ HIỂN THỊ)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Edit
              ElevatedButton.icon(
                onPressed: () => openForm(user: u),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryHeaderColor, // Nền vàng/kem
                  foregroundColor: _kEditTextColor, // Chữ/icon đen
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero, // Cho phép nút nhỏ hơn
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: Text('Edit', style: GoogleFonts.poppins(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              // Nút Delete
              ElevatedButton.icon(
                onPressed: () => deleteUser(u.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kDeleteButtonColor, // Nền đỏ
                  foregroundColor: Colors.white, // Chữ/icon trắng
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero, // Cho phép nút nhỏ hơn
                ),
                icon: const Icon(Icons.delete, size: 16),
                label: Text('Delete', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Hàm Build Chính ---
  @override
  Widget build(BuildContext context) {
    final filteredUsers = users
        .where(
          (u) =>
              u.username.toLowerCase().contains(search.toLowerCase()) ||
              u.email.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _kPrimaryHeaderColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            tooltip: 'Reload',
            onPressed: loadUsers,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red[600]),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(authService: widget.authService),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar và nút Add
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kCardBorderColor, width: 2), // VIỀN ĐẬM HƠN
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => setState(() => search = v),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Nút "Thêm"
                SizedBox(
                  width: 70,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _kAccentColor, // Màu #11224E
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kCardBorderColor, width: 2), // VIỀN ĐẬM HƠN
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black, size: 28),
                      onPressed: () => openForm(),
                      tooltip: 'Thêm người dùng',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User List (ĐÃ THAY THẾ bằng LayoutBuilder để hỗ trợ Grid/List)
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có người dùng',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Xác định ngưỡng chuyển đổi (600.0)
                        final isWideScreen = constraints.maxWidth >= 600;
                        final itemCount = filteredUsers.length;

                        if (isWideScreen) {
                          // Chế độ Grid 2 cột cho màn hình rộng
                          return GridView.builder(
                            itemCount: itemCount,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 cột
                              crossAxisSpacing: 16, // Khoảng cách giữa các cột
                              mainAxisSpacing: 16, // Khoảng cách giữa các hàng
                              childAspectRatio: 4, // Tỉ lệ chiều rộng/chiều cao
                            ),
                            itemBuilder: (_, i) {
                              final u = filteredUsers[i];
                              return _buildUserCard(u);
                            },
                          );
                        } else {
                          // Chế độ List mặc định cho màn hình hẹp
                          return ListView.builder(
                            itemCount: itemCount,
                            itemBuilder: (_, i) {
                              final u = filteredUsers[i];
                              return _buildUserCard(u);
                            },
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}