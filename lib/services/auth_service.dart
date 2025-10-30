import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'user_service.dart';

class AuthService {
  final UserService userService;

  AuthService({required this.userService});

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String image,
  ) async {
    final existing = await userService.getByEmail(email);
    if (existing != null) {
      return {'success': false, 'message': 'Email đã tồn tại'};
    }
    final user = User(
      id: '',
      username: username,
      email: email,
      passwordHash: hashPassword(password),
      image: image,
    );
    await userService.add(user);
    return {'success': true};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final user = await userService.getByEmail(email);
    if (user == null)
      return {'success': false, 'message': 'Không tìm thấy tài khoản'};
    if (hashPassword(password) != user.passwordHash) {
      return {'success': false, 'message': 'Sai mật khẩu'};
    }
    return {'success': true, 'user': user};
  }
}
