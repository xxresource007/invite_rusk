#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fz_invite_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fz_invite_kit'
  s.version          = '0.1.0'
  s.summary          = 'Flutter 邀请码插件'
  s.description      = <<-DESC
支持 Universal Links 和自定义 URL Scheme 的 Flutter 邀请码插件
                       DESC
  s.homepage         = 'https://github.com/funzonic/fz_invite_kit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Funzonic' => 'support@funzonic.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
