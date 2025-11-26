import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'fz_invite_kit_platform_interface.dart';
import 'models/invite_config.dart';

/// MethodChannel 实现类
class MethodChannelFzInviteKit extends FzInviteKitPlatform {
  MethodChannel? _channel;
  void Function(String code)? _inviteCodeCallback;

  @override
  Future<void> initialize(InviteConfig config) async {
    // 创建 MethodChannel
    _channel = MethodChannel(config.channelName);

    // 设置方法调用处理
    _channel!.setMethodCallHandler(_handleMethodCall);

    // 调用原生端的 initialize 方法,传递配置
    try {
      await _channel!.invokeMethod('initialize', config.toMap());
      if (kDebugMode) {
        print('✅ FzInviteKit 已初始化: ${config.channelName}');
        print('   Schemes: ${config.schemes}');
        print('   Domains: ${config.domains}');
        print('   Paths: ${config.validPaths}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FzInviteKit 初始化失败: $e');
      }
      rethrow;
    }
  }

  @override
  void setInviteCodeCallback(void Function(String code) callback) {
    _inviteCodeCallback = callback;
  }

  /// 处理来自原生端的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'receiveInviteCode':
        final String code = call.arguments as String;
        if (kDebugMode) {
          print('📥 Flutter 收到邀请码: $code');
        }
        _inviteCodeCallback?.call(code);
        break;
      default:
        if (kDebugMode) {
          print('⚠️ 未知方法调用: ${call.method}');
        }
    }
  }
}
