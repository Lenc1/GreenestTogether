import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/global_preference.dart';
import '../../theme/global.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _dio = Dio();
  static FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  String _username = '加载中...';
  String _newUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    String? token = await secureStorage.read(key: 'authToken');
    try {
      if (token != null) {
        final response = await _dio.get(
          '${API.reqUrl}/get_nickname',
          options: Options(
            headers: {
              'Authorization': token,
            },
          ),
        );
        setState(() {
          _username = response.data['nickname'] ?? '未知用户';
        });
      }
    } catch (e) {
      setState(() {
        _username = '无法获取用户名';
      });
    }
  }

  Future<void> _updateUsername() async {
    try {
      String? token = await secureStorage.read(key: 'authToken');
      if (token != null) {
        final response = await _dio.put(
          '${API.reqUrl}/update_nickname', // 使用全局 API.reqUrl
          data: {'nickname': _newUsername},
          options: Options(
            headers: {
              'Authorization': token,
            },
          ),
        );
        if (response.data['success']) {
          setState(() {
            _username = _newUsername;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('用户名修改成功')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('用户名修改失败')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误，请重试')),
      );
    }
  }

  void _showEditUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('修改用户名'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _newUsername = value;
              });
            },
            decoration: const InputDecoration(hintText: "输入新用户名"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateUsername();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人主页'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '用户名: $_username',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showEditUsernameDialog,
              child: const Text('修改用户名'),
            ),
          ],
        ),
      ),
    );
  }
}
