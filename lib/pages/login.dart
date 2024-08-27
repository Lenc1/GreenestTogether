import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_app/main.dart';
import 'package:local_app/pages/register.dart';
import 'package:local_app/pages/auth_service.dart';
import '../theme/global.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString errorMessage = ''.obs; // 用于显示错误信息
  bool isLoading = false; // 用于加载指示器
  late final FlutterSecureStorage secureStorage;
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    secureStorage = const FlutterSecureStorage();
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://112.124.62.169:5000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    )..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 从 FlutterSecureStorage 获取保存的令牌
          String? token = await secureStorage.read(key: 'authToken');
          try {
            await secureStorage.write(key: 'authToken', value: token);
            print('Token stored successfully.');
          } catch (e) {
            print('Failed to store token: $e');
          }

          // 如果令牌存在，将其添加到请求头中
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // 继续处理请求
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 在这里可以对响应数据进行处理
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          // 在这里可以对错误进行处理
          return handler.next(error);
        },
      ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.checkToken(context); // 检查令牌并处理页面跳转
    });
  }

  void _login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = "用户名或密码不能为空";
      return;
    }
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // 构建请求体
    Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };

    try {
      // 发送POST请求到服务器
      print(username);
      print(password);
      print(json.encode(data));

      final response = await dio.post(
        '/login', // 这里的路径将与 baseUrl 结合
        data: json.encode(data),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Response: ${response.data}');
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success']) {
          String token = responseData['token']; // 令牌
          await secureStorage.write(key: 'authToken', value: token);
          errorMessage.value = "登录成功！两秒后跳转……";
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage(title: '首页',)),
            );
          });
        } else {
          errorMessage.value = responseData['message'] ?? "用户名或密码错误";
        }
      } else {
        errorMessage.value = "服务器未查询到该用户，请检查用户名或密码";
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      setState(() {
        isLoading = false;
      });

      if (e.response != null) {
        errorMessage.value = e.response?.data['message'] ?? "服务器错误，请稍后再试";
      } else {
        errorMessage.value = "网络错误，请检查您的连接";
      }
    } catch (e) {
      print('Unknown Error: $e');
      setState(() {
        isLoading = false;
      });
      errorMessage.value = "未知错误，请稍后再试";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 60),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Obx(
                () => Text(
                  "欢迎登录",
                  style: TextStyle(
                    color: GlobalService.to.isDarkModel
                        ? Colors.white
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text("没有账户？点击注册"),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // 设置圆角半径
              ),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25), // 与 Container 的圆角一致
                  ),
                  labelText: '  用户名',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // 设置圆角半径
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(25), // 与 Container 的圆角一致
                  ),
                  labelText: '  密码',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => errorMessage.value.isNotEmpty
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        errorMessage.value,
                        style: errorMessage.value == '登录成功！两秒后跳转……' ? const TextStyle(color: Colors.green)
                            : const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  // 忘记密码的逻辑
                },
                child: const Text('忘记密码？'),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 24, // 设置加载动画的宽度
                        height: 24, // 设置加载动画的高度
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0, // 设置加载动画的线条宽度
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
