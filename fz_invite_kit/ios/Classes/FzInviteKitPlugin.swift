import Flutter
import UIKit

public class FzInviteKitPlugin: NSObject, FlutterPlugin {
  // MethodChannel 用于与 Flutter 通信
  private var inviteChannel: FlutterMethodChannel?
  
  // 临时存储邀请码,等待 Flutter 引擎准备好
  private var pendingInviteCode: String?
  
  // 临时存储 URL,等待初始化完成
  private var pendingURL: URL?
  
  // 配置参数
  private var validSchemes: [String] = []
  private var validDomains: [String] = []
  private var validPaths: [String] = []
  private var deferredLinkExpiryDays: Int = 7
  private var isInitialized: Bool = false
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.funzonic.invitedemo/invite",
      binaryMessenger: registrar.messenger()
    )
    let instance = FzInviteKitPlugin()
    instance.inviteChannel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // 注册为 Application Delegate
    registrar.addApplicationDelegate(instance)
    
    print("✅ FzInviteKitPlugin 已注册")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      if let args = call.arguments as? [String: Any] {
        validSchemes = args["schemes"] as? [String] ?? []
        validDomains = args["domains"] as? [String] ?? []
        validPaths = args["validPaths"] as? [String] ?? []
        deferredLinkExpiryDays = args["deferredLinkExpiryDays"] as? Int ?? 7
        isInitialized = true
        
        print("✅ FzInviteKit 初始化完成 - schemes: \(validSchemes), domains: \(validDomains), paths: \(validPaths)")
        
        // 初始化后检查是否有延迟的邀请码
        checkDeferredInviteCode()
        
        // 处理待处理的 URL (如果有)
        if let url = pendingURL {
          print("📦 处理待处理的 URL: \(url)")
          handleInviteURL(url)
          pendingURL = nil
        }
        
        result(true)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "参数无效", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

// MARK: - Universal Links 处理

extension FzInviteKitPlugin {
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]?) -> Void
  ) -> Bool {
    print("📱 FzInviteKit 收到 NSUserActivity: \(userActivity.activityType)")
    
    // 处理 Universal Links
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      print("🔗 Universal Links URL: \(url)")
      
      if !isInitialized {
        print("⏳ 插件尚未初始化,暂存 URL")
        pendingURL = url
        return true
      }
      
      handleInviteURL(url)
      return true
    }
    
    return false
  }
  
  public func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    print("🔗 FzInviteKit 收到自定义 URL: \(url)")
    
    if !isInitialized {
      print("⏳ 插件尚未初始化,暂存 URL")
      pendingURL = url
      return true
    }
    
    handleInviteURL(url)
    return true
  }
}

// MARK: - URL 解析逻辑

extension FzInviteKitPlugin {
  private func handleInviteURL(_ url: URL) {
    print("【FzInviteKit】收到 URL: \(url)  scheme: \(url.scheme ?? "无")")
    
    var code: String = ""
    
    // 情况1: Universal Links (https)
    if url.scheme?.lowercased() == "https" || url.scheme?.lowercased() == "http" {
      guard let host = url.host?.lowercased(),
            validDomains.contains(where: { host.contains($0) }) else {
        print("⚠️ https 域名不匹配")
        return
      }
      
      let path = url.path.lowercased()
      guard validPaths.contains(where: path.contains) else {
        print("⚠️ https 路径不匹配: \(path)")
        return
      }
      
      code = url.lastPathComponent.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    // 情况2: 自定义 scheme
    else if let scheme = url.scheme?.lowercased(), validSchemes.contains(scheme) {
      // 优先取 query 参数
      if let queryCode = url.queryParameters["code"], !queryCode.isEmpty {
        code = queryCode
      } else {
        code = url.lastPathComponent.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      }
    }
    
    // 最终检查
    guard !code.isEmpty else {
      print("⚠️ 没有提取到邀请码")
      return
    }
    
    let finalCode = code.uppercased()
    print("✅ 成功获取邀请码: \(finalCode)")
    applyInviteCode(finalCode)
  }
}

// MARK: - Deferred Deep Linking

extension FzInviteKitPlugin {
  private func checkDeferredInviteCode() {
    let key = "deferred_invite_code"
    let tsKey = "deferred_invite_timestamp"
    
    guard let code = UserDefaults.standard.string(forKey: key),
          let timestamp = UserDefaults.standard.object(forKey: tsKey) as? TimeInterval else {
      return
    }
    
    // 根据配置的天数判断有效期
    let expirySeconds = TimeInterval(deferredLinkExpiryDays * 24 * 3600)
    if Date().timeIntervalSince1970 - timestamp < expirySeconds {
      print("📦 恢复延迟邀请码: \(code)")
      applyInviteCode(code)
      
      // 用完清理
      UserDefaults.standard.removeObject(forKey: key)
      UserDefaults.standard.removeObject(forKey: tsKey)
    } else {
      print("⌛ 延迟邀请码已过期")
      UserDefaults.standard.removeObject(forKey: key)
      UserDefaults.standard.removeObject(forKey: tsKey)
    }
  }
  
  private func applyInviteCode(_ code: String) {
    print("💾 应用邀请码: \(code)")
    
    // 存储到 UserDefaults
    UserDefaults.standard.set(code, forKey: "deferred_invite_code")
    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "deferred_invite_timestamp")
    
    // 发送到 Flutter
    sendInviteCodeToFlutter(code)
  }
  
  private func sendInviteCodeToFlutter(_ code: String) {
    guard let channel = inviteChannel else {
      print("⚠️ MethodChannel 尚未准备好,暂存邀请码")
      pendingInviteCode = code
      return
    }
    
    print("📤 发送邀请码到 Flutter: \(code)")
    channel.invokeMethod("receiveInviteCode", arguments: code)
  }
}

// MARK: - URL 扩展

extension URL {
  var queryParameters: [String: String] {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else { return [:] }
    var params = [String: String]()
    for item in queryItems {
      if let value = item.value {
        params[item.name] = value
      }
    }
    return params
  }
}
