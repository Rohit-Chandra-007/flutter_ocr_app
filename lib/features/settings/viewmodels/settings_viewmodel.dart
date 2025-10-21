import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_info_model.dart';

part 'settings_viewmodel.g.dart';

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  void build() {}

  AppInfoModel get appInfo => AppInfoModel.current;
}
