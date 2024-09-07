import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/global_preference.dart';
import '../../theme/global.dart';
import '../login/login.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _dio = Dio();

  static FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  String _username = '加载中...';
  String _signature = '加载中...';
  String _gender = '加载中...';
  String _avatarPath = '';
  String _newUsername = '';
  String _newSignature = '';
  String _newGender = 'male';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    String? token = await secureStorage.read(key: 'authToken');
    String? avatarPath =
        await secureStorage.read(key: 'avatarPath'); // 读取本地存储的头像路径
    setState(() {
      _avatarPath = avatarPath ?? '';
    });

    try {
      if (token != null) {
        final response = await _dio.get(
          '${API.reqUrl}/get_user_info',
          options: Options(
            headers: {
              'Authorization': token,
            },
          ),
        );
        setState(() {
          _username = response.data['nickname'] ?? '未知用户';
          _signature = response.data['signature'] ?? '这个人很懒，什么都没写。';
          _gender = response.data['gender'] ?? '未设置';
          // 不再从服务器更新头像路径
        });
      }
    } catch (e) {
      setState(() {
        _username = '无法获取用户名';
        _signature = '无法获取签名';
        _gender = '无法获取性别';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _avatarPath = _imageFile!.path;
        API.avatarUrl = _imageFile!.path;
      });

      // 保存新的头像路径到本地存储
      await secureStorage.write(key: 'avatarPath', value: _avatarPath);

      _uploadAvatar(); //上传到服务器
    }
  }

  Future<void> _uploadAvatar() async {
    if (_imageFile == null) return;

    try {
      String? token = await secureStorage.read(key: 'authToken');
      if (token != null) {
        FormData formData = FormData.fromMap({
          "avatar": await MultipartFile.fromFile(_imageFile!.path),
        });
        final response = await _dio.post(
          '${API.reqUrl}/upload_avatar',
          data: formData,
          options: Options(
            headers: {
              'Authorization': token,
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像上传成功')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像上传失败')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('网络错误，请重试')),
      );
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      String? token = await secureStorage.read(key: 'authToken');
      if (token != null) {
        final response = await _dio.put(
          '${API.reqUrl}/update_user_info',
          data: {
            'nickname': _newUsername.isNotEmpty ? _newUsername : _username,
            'signature': _newSignature.isNotEmpty ? _newSignature : _signature,
            'gender': _newGender.isNotEmpty ? _newGender : _gender,
          },
          options: Options(
            headers: {
              'Authorization': token,
            },
          ),
        );

        if (response.data['success']) {
          setState(() {
            _username = _newUsername.isNotEmpty ? _newUsername : _username;
            _signature = _newSignature.isNotEmpty ? _newSignature : _signature;
            _gender = _newGender.isNotEmpty ? _newGender : _gender;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('用户信息修改成功')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('用户信息修改失败')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误，请重试')),
      );
    }
  }
  void _showEditUserDialog() {
    // 在显示弹窗前初始化新用户名和新签名
    _newUsername = _username;
    _newSignature = _signature;

    TextEditingController usernameController = TextEditingController(text: _newUsername);
    TextEditingController signatureController = TextEditingController(text: _newSignature);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('修改用户信息'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: usernameController,
                    onChanged: (value) {
                      _newUsername = value;
                    },
                    decoration: const InputDecoration(hintText: "输入新用户名"),
                  ),
                  TextField(
                    controller: signatureController,
                    onChanged: (value) {
                      _newSignature = value;
                    },
                    decoration: const InputDecoration(hintText: "输入新签名"),
                  ),
                  Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('男'),
                        leading: Radio<String>(
                          value: 'male',
                          groupValue: _newGender,
                          onChanged: (String? value) {
                            setState(() {
                              _newGender = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('女'),
                        leading: Radio<String>(
                          value: 'female',
                          groupValue: _newGender,
                          onChanged: (String? value) {
                            setState(() {
                              _newGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                ],
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
                    _updateUserInfo();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("资料"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15), // 设置距离右边30px
            child: FutureBuilder<String?>(
              future: secureStorage.read(key: 'authToken'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // 显示空白或加载动画
                }
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return IconButton(
                    icon: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "退出登录",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        Icon(Icons.logout),
                      ],
                    ),
                    onPressed: () async {
                      await secureStorage.delete(
                          key: 'authToken'); // 从SecureStorage删除Token
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipOval(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _avatarPath.isNotEmpty
                        ? Image.file(
                            File(_avatarPath),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(10),
              color:
                  GlobalService.to.isDarkModel ? Colors.white10 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '昵称: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$_username',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          '排名: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '999+',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          '签名: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$_signature',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          '性别: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if(_getGenderIcon(_gender) == Icons.male)
                              Icon(
                                _getGenderIcon(_gender),
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                              if( _getGenderIcon(_gender) == Icons.female)
                                Icon(
                                  _getGenderIcon(_gender),
                                  color: Colors.pinkAccent,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _showEditUserDialog,
                  child: const Text('修改用户信息'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
