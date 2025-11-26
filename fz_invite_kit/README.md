## fz_invite_kit

Flutter 邀请码插件,支持:
- ✅ Universal Links
- ✅ 自定义 URL Scheme  
- ✅ Deferred Deep Linking (延迟深度链接)
- ✅ 灵活配置域名、路径和 scheme

## 安装

在 `pubspec.yaml` 中添加:

```yaml
dependencies:
  fz_invite_kit:
    path: ./fz_invite_kit
```

或发布到 pub.dev 后:

```yaml
dependencies:
  fz_invite_kit: ^0.1.0
```

## 使用方法

### 1. 在 Flutter 中初始化

```dart
import 'package:fz_invite_kit/fz_invite_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化插件
  await FzInviteKit.initialize(
    config: InviteConfig(
      channelName: 'com..invitedemo/invite',
      schemes: ['', 'myapp'], // 自定义 URL Scheme
      domains: ['.com'], // Universal Links 域名
      validPaths: ['/invite_test/invite/', '/invite/', '/i/'], // 有效路径
      deferredLinkExpiryDays: 7, // 延迟链接有效期(天)
    ),
    onInviteCodeReceived: (code) {
      print('📥 收到邀请码: $code');
      // 在这里处理邀请码,例如保存到状态管理或导航到注册页
    },
  );
  
  runApp(MyApp());
}
```

### 2. iOS 配置

#### 在 `Info.plist` 中添加自定义 URL Scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com..invitedemo</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>wclinksdemo</string>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

#### 配置 Associated Domains (Universal Links):

1. 在 Xcode 中打开项目
2. 选择 Target → Signing & Capabilities
3. 添加 "Associated Domains"
4. 添加域名: `applinks:.com`

#### 简化 AppDelegate.swift:

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 支持的 URL 格式

### Universal Links (需要配置 Associated Domains)
- `https://.com/invite/ABC123`
- `https://.com/i/ABC123`
- `https://.com/invite_test/invite/ABC123`

### 自定义 Scheme
- `://invite?code=ABC123`
- `myapp://invite/ABC123`

## 注意事项

1. **iOS 配置**: 必须在 Info.plist 和 Associated Domains 中正确配置
2. **域名验证**: Universal Links 需要在服务器上配置 `apple-app-site-association` 文件
3. **测试**: 在真机上测试 Universal Links,模拟器可能不生效

## License

MIT
