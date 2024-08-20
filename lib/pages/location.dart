import 'dart:async';
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/material.dart';
import 'package:local_app/config/config.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _latitude = ""; //纬度
  String _longitude = ""; //经度
  String country = ""; // 国家
  String province = ""; // 省份
  String city = ""; // 市
  String district = ""; // 区
  String street = ""; // 街道
  String adCode = ""; // 邮编
  String address = ""; // 详细地址
  String cityCode = ""; //区号

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  late StreamSubscription<Map<String, Object>> _locationListener;

  @override
  void initState() {
    super.initState();
    requestPermission();
    AMapFlutterLocation.setApiKey(ConstConfig.androidKey, ConstConfig.iosKey);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.updatePrivacyShow(true, true);

    if (Platform.isIOS) {
      requestAccuracyAuthorization();
    }

    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      print(result);

      setState(() {
        _latitude = result["latitude"].toString();
        _longitude = result["longitude"].toString();
        country = result['country'].toString();
        province = result['province'].toString();
        city = result['city'].toString();
        district = result['district'].toString();
        street = result['street'].toString();
        adCode = result['adCode'].toString();
        address = result['address'].toString();
        cityCode = result['cityCode'].toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (null != _locationListener) {
      _locationListener.cancel();
    }

    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }
  }

  void requestPermission() async {
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  void requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
    await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }

  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = AMapLocationOption();
      locationOption.onceLocation = false;
      locationOption.needAddress = true;
      locationOption.geoLanguage = GeoLanguage.DEFAULT;
      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;
      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";
      locationOption.locationInterval = 2000;
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;
      locationOption.distanceFilter = -1;
      locationOption.desiredAccuracy = DesiredAccuracy.Best;
      locationOption.pausesLocationUpdatesAutomatically = false;

      _locationPlugin.setLocationOption(locationOption);
    }
  }

  void _startLocation() {
    if (null != _locationPlugin) {
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  void _stopLocation() {
    if (null != _locationPlugin) {
      _locationPlugin.stopLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定位'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
          children: [
            Text("经度: $_longitude"),
            Text("纬度: $_latitude"),
            Text('国家：$country'),
            Text('省份：$province'),
            Text('城市：$city'),
            Text('区：$district'),
            Text('城市编码：$cityCode'),
            Text('街道：$street'),
            Text('邮编：$adCode'),
            Text('详细地址：$address'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('开始定位'),
              onPressed: _startLocation,
            ),
            ElevatedButton(
              child: const Text('停止定位'),
              onPressed: _stopLocation,
            ),
          ],
        ),
      ),
    );
  }
}
