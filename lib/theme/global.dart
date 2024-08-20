import 'package:get/get.dart';
import 'package:local_app/theme/theme.dart';

class GlobalService extends GetxService {
  Future<GlobalService> init() async {
    return this;
  }

  static GlobalService get to => Get.find();

  final _isDarkModel = Get.isDarkMode.obs;

  get isDarkModel => _isDarkModel.value;

  set isDarkModel(value) => _isDarkModel.value = value;

  //深色模式开关
  void switchThemeModel() {
    _isDarkModel.value = !_isDarkModel.value;
    Get.changeTheme(
        _isDarkModel.value == true ? AppTheme.dark : AppTheme.light);
  }
}
