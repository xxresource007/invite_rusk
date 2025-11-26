import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'fz_invite_kit_method_channel.dart';
import 'models/invite_config.dart';

/// 平台接口抽象类
abstract class FzInviteKitPlatform extends PlatformInterface {
  FzInviteKitPlatform() : super(token: _token);

  static final Object _token = Object();
  static FzInviteKitPlatform _instance = MethodChannelFzInviteKit();

  /// 当前平台实例
  static FzInviteKitPlatform get instance => _instance;

  /// 设置平台实例 (用于测试)
  static set instance(FzInviteKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化插件
  Future<void> initialize(InviteConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// 设置邀请码回调
  void setInviteCodeCallback(void Function(String code) callback) {
    throw UnimplementedError('setInviteCodeCallback() has not been implemented.');
  }
}
