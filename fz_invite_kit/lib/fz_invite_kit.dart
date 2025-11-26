library fz_invite_kit;

export 'models/invite_config.dart';
export 'fz_invite_kit_platform_interface.dart';

import 'fz_invite_kit_platform_interface.dart';
import 'models/invite_config.dart';

/// FzInviteKit 主类
class FzInviteKit {
  /// 初始化插件
  /// 
  /// [config] 插件配置
  /// [onInviteCodeReceived] 收到邀请码时的回调
  /// 
  /// 示例:
  /// ```dart
  /// await FzInviteKit.initialize(
  ///   config: InviteConfig(
  ///     channelName: 'com.funzonic.app/invite',
  ///     schemes: ['myapp'],
  ///     domains: ['funzonic.com'],
  ///     validPaths: ['/invite/', '/i/'],
  ///   ),
  ///   onInviteCodeReceived: (code) {
  ///     print('收到邀请码: $code');
  ///   },
  /// );
  /// ```
  static Future<void> initialize({
    required InviteConfig config,
    required void Function(String code) onInviteCodeReceived,
  }) async {
    // 设置回调
    FzInviteKitPlatform.instance.setInviteCodeCallback(onInviteCodeReceived);
    
    // 初始化平台实现
    await FzInviteKitPlatform.instance.initialize(config);
  }
}
