import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // <-- CẦN THÊM IMPORT NÀY
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';

// --- COLOR CONSTANTS (Matching AdminScreen) ---
const Color _kPrimaryHeaderColor = Color(0xFFF0E68C); // Khaki (Yellow/Cream)
const Color _kBackgroundColor = Color(0xFFF9F9F9); 
const Color _kAccentColor = Color(0xFF11224E); // Dark Blue/Black for focus
const Color _kCardBorderColor = Color(0xFF424242); // Dark Gray for heavy borders
const Color _kTextColorOnPrimary = Colors.black;
const Color _kCancelButtonColor = Colors.grey; 

// Define the widget
class UserFormScreen extends StatefulWidget {
  final User? user;
  final Function(String username, String email, String password, String image) onSave;

  const UserFormScreen({
    super.key,
    this.user,
    required this.onSave,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  // Tên biến được đổi để rõ ràng hơn
  String _currentImageBase64 = ''; 
  Uint8List? _imageBytes;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();

    if (widget.user != null && widget.user!.image.isNotEmpty) {
      _currentImageBase64 = widget.user!.image;
      // Khởi tạo _imageBytes từ base64 có sẵn
      try {
        _imageBytes = base64Decode(_currentImageBase64);
      } catch (e) {
        _imageBytes = null;
        debugPrint('Error decoding base64 image: $e');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // --- LOGIC CHỌN ẢNH CHO WEB (ĐÃ THAY THẾ) ---
  void _pickImage() async {
    // 1. Tạo input file element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Chỉ chấp nhận file ảnh
    uploadInput.click(); // Mở hộp thoại chọn file

    // 2. Lắng nghe sự kiện thay đổi (khi người dùng chọn file)
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      
      final file = files.first;
      final reader = html.FileReader();
      
      // 3. Đọc file dưới dạng Data URL (để lấy Base64)
      reader.readAsDataUrl(file);
      
      reader.onLoadEnd.listen((e) {
        if (reader.result is String) {
          final String base64Full = reader.result as String;
          // Lấy phần Base64 thuần túy (bỏ "data:image/...;base64,")
          final String base64Data = base64Full.split(',').last;
          
          setState(() {
            _currentImageBase64 = base64Data; // Cập nhật chuỗi base64
            // Chuyển sang Uint8List để hiển thị ngay lập tức
            try {
              _imageBytes = base64Decode(base64Data);
            } catch (e) {
              _imageBytes = null;
            }
          });
        }
      });
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _currentImageBase64, // Dùng biến Base64 đã cập nhật
      );
      Navigator.pop(context);
    }
  }
  
  // --- Custom TextField Widget (Border and Shadow applied) ---
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    // ... (Code TextField giữ nguyên)
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      // Apply shadow for Input Field
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          
          filled: true,
          fillColor: Colors.white,
          
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 16),
          
          // Consistent border style
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kCardBorderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kCardBorderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kAccentColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (!isEditing || !isPassword) {
              return '$labelText is required.';
            }
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
            return 'Enter a valid Email.';
          }
          // Only enforce password length when creating a new user or if password field is filled during edit
          if (isPassword && value!.isNotEmpty && value.length < 6) { 
             return 'Password must be at least 6 characters.';
          }
          if (isPassword && !isEditing && value!.isEmpty) {
             return 'Password is required.';
          }
          return null;
        },
      ),
    );
  }

  // --- Main Build Function ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPrimaryHeaderColor,
      appBar: AppBar(
        backgroundColor: _kPrimaryHeaderColor,
        elevation: 0,
        // Only keep the Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''), // Title removed from AppBar
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center items
            children: [
              // --- CENTERED TITLE ABOVE THE FORM CARD ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  isEditing ? 'Edit User' : 'Add New User',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              // --- Form Card Container ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Image/Avatar Placeholder (Large size) ---
                      GestureDetector(
                        onTap: _pickImage, // GỌI HÀM CHỌN ẢNH MỚI
                        child: CircleAvatar(
                          radius: 50, // Large size
                          backgroundColor: Colors.grey.shade200, 
                          backgroundImage: _imageBytes != null 
                              ? MemoryImage(_imageBytes!) 
                              : null,
                          child: _imageBytes == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      // --- Input Fields ---
                      _buildCustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        icon: Icons.person,
                      ),
                      
                      _buildCustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email,
                        isEmail: true,
                      ),
                      
                      _buildCustomTextField(
                        controller: _passwordController,
                        // Contextual Label Text based on isEditing
                        labelText: isEditing 
                            ? 'Password (leave blank to keep current)'
                            : 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // --- Buttons (No Border, with Shadow) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel Button (Gray, No Border)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kCancelButtonColor, // Gray
                                  foregroundColor: Colors.white,
                                  // No border (side removed)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Save Button (Yellow/Cream, No Border)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kPrimaryHeaderColor, // Yellow/Cream
                                  foregroundColor: _kTextColorOnPrimary, // Black
                                  // No border (side removed)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Save',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
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