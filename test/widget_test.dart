import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_danentang_01/main.dart';
import 'package:flutter_danentang_01/services/user_service.dart';
import 'package:flutter_danentang_01/services/auth_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Tạo các service thật
    final userService = UserService();
    final authService = AuthService(userService: userService);
    // Chạy ứng dụng
   await tester.pumpWidget(MyApp(authService: authService));
    // Kiểm tra xem có hiển thị màn hình đăng nhập hay không
    expect(find.text('Login'), findsOneWidget);

    // Có thể kiểm tra thêm nút đăng ký hoặc đăng nhập
    expect(find.text('Register'), findsOneWidget);
  });
}
