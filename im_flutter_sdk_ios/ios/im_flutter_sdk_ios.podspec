#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'im_flutter_sdk_ios'
  s.version          = '4.22.0'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = 'im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/**/*'
  s.public_header_files = 'im_flutter_sdk_ios/Sources/im_flutter_sdk_ios/include/im_flutter_sdk_ios/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'HyphenateChat','4.22.2'
  # s.dependency 'ShengwangChat_iOS','1.3.2'
  # 注释掉本地 framework，使用 CocoaPods 依赖
  # s.ios.vendored_frameworks = 'framework/HyphenateChat.xcframework', 'framework/aosl.xcframework'
  s.ios.deployment_target = '13.0'

end

