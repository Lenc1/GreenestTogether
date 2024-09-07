import 'dart:io';
import 'dart:math';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:local_app/config/config.dart';
import 'package:local_app/pages/location.dart';
import 'package:local_app/theme/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/global_preference.dart'; // 新增
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  AMapController? mapController;
  AMapFlutterLocation? location;
  PermissionStatus? permissionStatus;
  CameraPosition? currentLocation;
  late MapType _mapType;
  List<LatLng> _savedLocations = [];
  List<String> _locationNotes = [];
  List poisData = [];
  var markerLatitude;
  var markerLongitude;
  double? meLatitude;
  double? meLongitude;
  bool _firstTimeIn = true;
  final LatLng defaultLocation = LatLng(39.908823, 116.397470);

  @override
  void initState() { //初始化
    super.initState();
    //初始化地图，根据颜色模式自动设置
    _mapType = GlobalService.to.isDarkModel ? MapType.night : MapType.normal;
    AMapFlutterLocation.setApiKey(ConstConfig.androidKey, ConstConfig.iosKey);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.updatePrivacyShow(true, true);
    currentLocation = CameraPosition(target: defaultLocation, zoom: API.zoom);
    requestPermission();
  }
  Future<void> _loadSavedLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? latitudes = prefs.getStringList('latitudes');
    List<String>? longitudes = prefs.getStringList('longitudes');
    _locationNotes = prefs.getStringList('locationNotes') ?? [];

    if (latitudes != null && longitudes != null && latitudes.length == longitudes.length) {
      setState(() {
        _savedLocations = List.generate(latitudes.length, (index) {
          LatLng location = LatLng(double.parse(latitudes[index]), double.parse(longitudes[index]));
          _addMarker(location);  // 添加标记
          return location;
        });
      });
    }
  }

  Future<void> _saveLocations() async { //保存位置
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> latitudes = _savedLocations.map((loc) => loc.latitude.toString()).toList();
    List<String> longitudes = _savedLocations.map((loc) => loc.longitude.toString()).toList();
    await prefs.setStringList('latitudes', latitudes);
    await prefs.setStringList('longitudes', longitudes);
    await prefs.setStringList('locationNotes', _locationNotes); // 保存备注
  }
  void _editLocationNoteDialog(int index) {
    String editedNote = _locationNotes[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('编辑备注'),
          content: TextField(
            onChanged: (value) {
              editedNote = value;
            },
            controller: TextEditingController(text: _locationNotes[index]),
            decoration: const InputDecoration(hintText: "输入新的位置备注"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _locationNotes[index] = editedNote.isEmpty ? '暂无备注' : editedNote; // 更新备注
                  _saveLocations(); // 保存更新后的备注
                });
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
  void _saveCurrentLocation() {
    if (markerLatitude != null && markerLongitude != null) {
      setState(() {
        _savedLocations.add(LatLng(double.parse(markerLatitude), double.parse(markerLongitude)));
        _showSaveDialog();
      });
    } else {
      _showCanNotSaveDialog();
    }
  }
  void _showSaveDialog() {
    String remark = ""; // remark 初始化为空字符串
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加备注'),
          content: TextField(
            onChanged: (value) {
              remark = value; // 当输入改变时，更新remark变量的值
            },
            decoration: const InputDecoration(hintText: "输入位置备注"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _locationNotes.add('无备注');
                  _saveLocations();
                  Navigator.of(context).pop();
                  _showSuccessDialog();
                });
              },
              child: const Text('不添加备注'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (remark.isEmpty) {
                    _locationNotes.add('无备注');
                  } else {
                    _locationNotes.add(remark);
                  }
                  _saveLocations();
                  Navigator.of(context).pop();
                  _showSuccessDialog();
                });
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermission() async {
    final status = await Permission.location.request();
    permissionStatus = status;
    switch (status) {
      case PermissionStatus.denied:
        print("拒绝");
        break;
      case PermissionStatus.granted:
        requestLocation();
        break;
      case PermissionStatus.limited:
        print("限制");
        break;
      default:
        print("其他状态");
        requestLocation();
        break;
    }
  }

  void requestLocation() {
    location = AMapFlutterLocation()
      ..setLocationOption(AMapLocationOption())
      ..onLocationChanged().listen((event) {
        double? latitude = double.tryParse(event['latitude'].toString());
        double? longitude = double.tryParse(event['longitude'].toString());
        meLatitude = latitude;
        meLongitude = longitude;
        if(meLongitude != null && _firstTimeIn) _changeCameraPosition(LatLng(meLatitude!, meLongitude!));
        if (latitude != null && longitude != null) {
          _firstTimeIn = false; //首次失效
          setState(() {
            currentLocation = CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 30,
            );
            _loadSavedLocations();
          });
        }
      })
      ..startLocation();
  }

  void _onMapPoiTouched(AMapPoi poi) async {
    if (poi == null) {
      return;
    }
    print('_onMapPoiTouched===> ${poi.toJson()}');
    var latLng = poi.latLng!;
    markerLatitude = latLng.latitude.toString();
    markerLongitude = latLng.longitude.toString();

    // 移除所有当前标记
    _removeAll();

    // 添加新标记到点击位置
    _addMarker(latLng);

    // 移动相机到点击位置
    _changeCameraPosition(latLng);
  }

  final Map<String, Marker> _markers = <String, Marker>{};

  void _addMarker(LatLng markPostion) {
    final String markerId = markPostion.toString(); // 使用位置作为标记ID
    final Marker marker = Marker(
      position: markPostion,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: '保存的位置'),
    );
    setState(() {
      _markers[markerId] = marker;
    });

  }

  void _removeAll() {
    if (_markers.isNotEmpty) {
      setState(() {
        _markers.clear();
      });
    }
  }

  void _changeCameraPosition(LatLng markPostion, {double zoom = 30}) {
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: markPostion,
          zoom: API.seZoom,
          tilt: 30,
          bearing: 0,
        ),
      ),
      animated: true,
    );
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    print("当前位置: $meLatitude, $meLongitude");
    print("标记位置: $markerLatitude, $markerLongitude");
    const double earthRadius = 6371000; // 单位：米
    final double dLat = _degreeToRadian(point2.latitude - point1.latitude);
    final double dLng = _degreeToRadian(point2.longitude - point1.longitude);
    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degreeToRadian(point1.latitude)) *
                cos(_degreeToRadian(point2.latitude)) *
                (sin(dLng / 2) * sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  @override
  void dispose() {
    location?.destroy();
    super.dispose();
  }
  void _showErrorDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误：'),
          content: const Text('无法计算距离\n请选择一个标点'),
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
  void _showCanNotSaveDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误：'),
          content: const Text('无法保存\n请选择一个标点'),
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
  void _showDistanceDialog(BuildContext context, double distance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('碳足迹'),
          content: Text('当前距离: ${distance.toStringAsFixed(2)} 公里\n选择绿色出行，将减少${(7.5 * 0.01 * distance).toStringAsFixed(2)}kg碳排放'),
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
  Future<void> _searchPlace(String keyword) async {
    final Dio dio = Dio();
    const String url = "https://restapi.amap.com/v3/place/text";

    // 确保 API Key 的正确性
    final Map<String, String> queryParameters = {
      'key': ConstConfig.androidKey, // 使用你配置的 key
      'keywords': keyword,
      'city': "北京", // 设置默认城市为北京
      'children': "1",
      'offset': "20",
      'page': "1",
      'extensions': "all",
    };

    try {
      // 发送请求
      final response = await dio.get(url, queryParameters: queryParameters);

      // 检查响应数据
      if (response.statusCode == 200) {
        final responseData = response.data;
        // 检查 'pois' 字段是否存在且不为空
        if (responseData['pois'] != null && responseData['pois'].isNotEmpty) {
          // 如果有结果，则显示搜索结果
          _showSearchResults(responseData['pois']);
        } else {
          // 如果没有找到结果，显示无结果对话框
          _showNoResultsDialog();
        }
      } else {
        // 如果响应状态码不是 200，处理异常
        print("错误：请求失败，状态码：${response.statusCode}");
        //_showErrorDialog("请求失败，状态码：${response.statusCode}");
      }
    } catch (e) {
      // 捕获请求中的任何错误
      print("错误：$e");
      //_showErrorDialog(e.toString());
    }
  }

  void _showSearchResults(List pois) {
    _removeAll();
    setState(() {
      for (var poi in pois) {
        LatLng location = LatLng(double.parse(poi['location'].split(",")[1]), double.parse(poi['location'].split(",")[0]));
        _addMarker(location);
      }
    });
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('没有结果'),
          content: const Text('未找到符合条件的地点，请尝试其他关键字。'),
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
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('保存成功'),
          content: const Text('当前位置已成功保存！'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  void _deleteLocation(int index) {
    setState(() {
      _savedLocations.removeAt(index);
      _locationNotes.removeAt(index);
      _saveLocations();
    });
  }
  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 返回按钮
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
        title: TextField(
          decoration: InputDecoration(
              hintText: "搜索地点",
              suffixIcon: IconButton(
                icon: Icon(Icons.search_outlined),
                onPressed: () {
                  _searchPlace('天安门');
                },
              )
          ),
          onSubmitted: (value) {
            _searchPlace(value);
          },
        ),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open), // Drawer 弹出按钮
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
                ? const Color(0xFF2F2E33) // 黑暗模式下的背景颜色
                : Colors.white,  // 亮模式下的背景颜色
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
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                      const Text('保存的位置', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _savedLocations.length,
                    itemBuilder: (context, index) {
                      final location = _savedLocations[index];
                      final note = _locationNotes[index]; // 获取备注
                      return Slidable(
                        key: Key(location.toString()),
                        direction: Axis.horizontal,
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteLocation(index),
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
                          title: Text(note.isEmpty ? '暂无备注' : note),
                          subtitle: Text('◎${index + 1}(${location.latitude.toStringAsFixed(6)} , ${location.longitude.toStringAsFixed(6)})'), // 显示备注
                          onTap: () {
                            _removeAll();
                            _addMarker(location);
                            markerLongitude = location.longitude.toString();
                            markerLatitude = location.latitude.toString();
                            Navigator.of(context).pop(); // 关闭Drawer
                            _changeCameraPosition(location); // 移动到选中的位置
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editLocationNoteDialog(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("删除所有位置",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),),
                      Icon(Icons.delete),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _removeAll();
                      _savedLocations.clear();
                      _locationNotes.clear(); // 清空备注
                      _saveLocations();
                    });
                    Navigator.of(context).pop(); // 关闭Drawer
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: currentLocation == null
          ? const Stack(
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ]
      )
          : Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // 将地图视图扩大
                child: SizedBox(
                  child: AMapWidget(
                    privacyStatement: ConstConfig.amapPrivacyStatement,
                    apiKey: ConstConfig.amapApiKeys,
                    initialCameraPosition: currentLocation!,
                    myLocationStyleOptions: MyLocationStyleOptions(true),
                    mapType: _mapType,
                    minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
                    onPoiTouched: _onMapPoiTouched,
                    markers: Set<Marker>.of(_markers.values),
                    onMapCreated: (AMapController controller) {
                      mapController = controller;
                      _loadSavedLocations();
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: (){
                  _changeCameraPosition(LatLng(meLatitude!, meLongitude!));
                },
                child: const Icon(
                    Icons.gps_fixed
                ),
              )
          ),
          Positioned(
            top: 156,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (meLatitude != null &&
                    meLongitude != null &&
                    markerLatitude != null &&
                    markerLongitude != null) {
                  final distance = calculateDistance(
                    LatLng(meLatitude!, meLongitude!),
                    LatLng(double.parse(markerLatitude), double.parse(markerLongitude)),
                  ) / 1000;
                  _showDistanceDialog(context, distance); // 弹出提示框
                } else {
                  _showErrorDialog();
                }
              },
              child: const Icon(Icons.straighten),
            ),
          ),
          Positioned(
            top: 86,
            right: 16,
            child: FloatingActionButton(
              onPressed: _saveCurrentLocation,
              child: const Icon(Icons.add_location_alt_rounded), // 添加保存按钮
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            label: '普通地图',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.normal;
              });
            },
          ),
          SpeedDialChild(
            label: '卫星地图',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.satellite;
              });
            },
          ),
          SpeedDialChild(
            label: '导航地图',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.navi;
              });
            },
          ),
          SpeedDialChild(
            label: '公交地图',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.bus;
              });
            },
          ),
          SpeedDialChild(
            label: '黑夜模式',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.night;
              });
            },
          ),
        ],
      ),
    );
  }
}