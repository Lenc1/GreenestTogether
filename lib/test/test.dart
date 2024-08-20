import 'package:dio/dio.dart';

void main() {
  // 在主函数中调用你的调试代码
  uploadImage("OIP.jpg");
}

void uploadImage(String filePath) async {
  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10), // 连接超时时间
    receiveTimeout: Duration(seconds: 10), // 响应超时时间
    sendTimeout: Duration(seconds: 10),    // 发送超时时间
    followRedirects: true, // 自动跟随重定向
    validateStatus: (status) => status! < 500, // 允许 3xx 状态码
  ));

  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(filePath, filename: "upload.jpg"),
  });

  String url = "http://192.168.110.159:5000"; // 使用你的 Flask 服务器 IP 地址
  try {
    print("发送 POST 请求到: $url");

    var response = await dio.post(url, data: formData);
    var data = response.data;
    print("响应状态码: ${response.statusCode}");
    print("响应数据: ${response.data}");
    print(data['answer']);
  } catch (e) {
    print("POST 请求错误: $e");
  }
  // try {
  //   String getUrl = "$url"; // 修改为你的 GET 请求路径
  //
  //   print("发送 GET 请求到: $getUrl");
  //
  //   var response = await dio.get(getUrl);
  //   print("响应状态码: ${response.statusCode}");
  //   if(response.statusCode == 200){
  //     print("请求成功");
  //     var data = response.data;
  //     print(data["anwser"]);
  //   }
  // } catch (e) {
  //   print("$e");
  // }
}
