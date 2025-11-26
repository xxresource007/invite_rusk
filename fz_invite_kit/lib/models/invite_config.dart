/// 邀请配置类
class InviteConfig {
  /// MethodChannel 名称
  final String channelName;

  /// 支持的自定义 URL Schemes (例如: ['myapp', 'wclinksdemo'])
  final List<String> schemes;

  /// 支持的域名 (例如: ['funzonic.com'])
  final List<String> domains;

  /// 有效的路径关键词 (例如: ['/invite/', '/i/'])
  final List<String> validPaths;

  /// 延迟深度链接有效期天数 (默认7天)
  final int deferredLinkExpiryDays;

  const InviteConfig({
    required this.channelName,
    required this.schemes,
    required this.domains,
    required this.validPaths,
    this.deferredLinkExpiryDays = 7,
  });

  /// 转换为 Map,传递给原生端
  Map<String, dynamic> toMap() {
    return {
      'channelName': channelName,
      'schemes': schemes,
      'domains': domains,
      'validPaths': validPaths,
      'deferredLinkExpiryDays': deferredLinkExpiryDays,
    };
  }
}
