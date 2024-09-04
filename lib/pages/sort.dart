import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // 导入image库
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/global_preference.dart';
import '../theme/global.dart'; // 获取临时目录

class SortPage extends StatefulWidget {
  const SortPage({super.key});

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  File? _image; // 保存用户选择的当前图片
  File? _imageup;
  String? _result; // 保存分类结果
  bool _isLoading = false; // 控制加载动画的显示
  List<File> _imageHistory = []; // 保存图片历史记录
  List<String> _imageResults = []; // 保存识别结果

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
    await Hive.openBox('recognition_history');
    _loadRecognitionHistory();
  }

  void _loadRecognitionHistory() {
    var box = Hive.box('recognition_history');
    setState(() {
      _imageHistory = box.values.map((entry) {
        return File(entry['imagePath']);
      }).toList();

      // 强制将结果转换为 List<String> 类型
      _imageResults = box.values.map<String>((entry) {
        return entry['result'] ?? ''; // 使用 ?? 确保返回的是字符串
      }).toList();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误：'),
          content: const Text('未能上传一张图片'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 请求相机权限
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  // 打开相机拍照
  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  // 从相册中选择图片
  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _imageHistory.removeAt(index);
      _imageResults.removeAt(index);
    });

    var box = Hive.box('recognition_history');
    box.deleteAt(index);
  }

  // 向服务器发送图片并获取识别结果
  Future<void> _sendImageToServer() async {
    if (_image == null) {
      _showErrorDialog();
      print('No image to upload.');
      return;
    }
    setState(() {
      _isLoading = true; // 显示加载动画
    });

    // 读取图片字节
    final bytes = await _image!.readAsBytes();
    // 使用image库进行压缩
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      img.Image resizedImage = img.copyResize(image, width: 400);
      // 将压缩后的图片编码为JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final compressedImagePath = '${tempDir.path}/compressed_image.jpg';
      final compressedImageFile =
          await File(compressedImagePath).writeAsBytes(compressedBytes);
      // 更新_image为压缩后的图片文件
      _imageup = compressedImageFile;
    }

    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (status) => status! < 500,
    ));

    FormData formData = FormData.fromMap({
      'file':
          await MultipartFile.fromFile(_imageup!.path, filename: 'upload.jpg'),
    });
    String url = API.sortUrl; // 服务器地址和端点,更换服务器时修改
    try {
      print("发送 POST 请求到: $url");
      var response = await dio.post(
        url,
        data: formData,
      );
      if (response.statusCode == 200) {
        print("响应状态码: ${response.statusCode}");
        print("响应数据: ${response.data}");
        var data = response.data;
        setState(() {
          _result = data['answer']; // 显示服务器返回的分类结果
        });
        // 保存图片路径和识别结果到 Hive
        var box = Hive.box('recognition_history');
        box.add({
          'imagePath': _image!.path,
          'result': _result ?? "识别失败",
        });
      } else {
        print('Request status: ${response.statusCode}');
      }
      if (_image != null && !_imageHistory.contains(_image)) {
        setState(() {
          _imageHistory.add(_image!);
          _imageResults.add(_result ?? "识别失败"); // 将识别结果保存到列表中
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // 隐藏加载动画
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别可回收垃圾'),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history), // Drawer 弹出按钮
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // 打开 Drawer
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Obx(
          () => Container(
            color: GlobalService.to.isDarkModel
                ? const Color(0xFF2F2E33)
                : Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 30, 20, 0),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                      const Text('识别记录',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _imageHistory.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: Key(_imageHistory[index].path),
                        direction: Axis.horizontal,
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteImage(index),
                              foregroundColor: GlobalService.to.isDarkModel
                                  ? Colors.black45
                                  : Colors.white,
                              backgroundColor: GlobalService.to.isDarkModel
                                  ? Colors.white
                                  : Colors.black45,
                              icon: Icons.delete,
                              label: '删除',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_imageHistory[index],
                                width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(
                            _imageResults[index] == '可回收垃圾' ? '可回收' : '不可回收',
                            style: _imageResults[index] == '可回收垃圾'
                                ? const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.green,
                                  )
                                : const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.deepOrange,
                                  ),
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("删除所有记录",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                        Icon(Icons.delete),
                      ]),
                  onTap: () {
                    setState(() {
                      _imageHistory.clear();
                      _imageResults.clear();
                    });
                    var box = Hive.box('recognition_history');
                    box.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_result == null) const SizedBox(height: 18), // 间距
              if (_image != null)
                Stack(
                  children: [
                    // 图片容器
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                          colorFilter: _isLoading
                              ? ColorFilter.mode(
                              Colors.white.withOpacity(0.5), BlendMode.dstATop)
                              : null, // 设置图片的半透明效果
                        ),
                      ),
                      height: 250,
                      width: 250,
                    ),
                    if (_isLoading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(), // 显示加载动画
                        ),
                      ),
                  ],
                ),
              if (_image == null)
                const Icon(Icons.photo_size_select_actual_outlined, size: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 水平方向居中
                children: [
                  if (_result != null && _result != '识别中...')
                    const Text(
                      '识别结果：',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  if (_result == '识别中...')
                    Text(
                      '$_result',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  if (_result == '可回收垃圾' || _result == 'Recycle')
                    Text(
                      '$_result',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  if (_result == '不可回收垃圾' || _result == 'Organic')
                    Text(
                      '$_result',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.deepOrange,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            if (_image != null && _result == null)
              ElevatedButton(
                onPressed: () async {
                  _result = '识别中...';
                  await _sendImageToServer(); // 发送图片到服务器
                },
                child: const Text('上传图片'),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    _result = null;
                    await _getImageFromCamera();
                  },
                  label: const Text('拍照识别'),
                  icon: const Icon(Icons.photo_camera),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    _result = null;
                    await _getImageFromGallery();
                  },
                  label: const Text('相册选择'),
                  icon: const Icon(Icons.photo_album),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
