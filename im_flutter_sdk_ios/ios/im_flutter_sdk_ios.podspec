#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  ios_sdk_flavor = ENV['IM_IOS_SDK_FLAVOR'].to_s
  wrapper_source_dir = ios_sdk_flavor.empty? || ios_sdk_flavor == 'sdk500' ? 'Classes/base500' : 'Classes/generated/active'

  s.name             = 'im_flutter_sdk_ios'
  s.version          = '4.15.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = "#{wrapper_source_dir}/**/*"
  s.public_header_files = "#{wrapper_source_dir}/**/*.h"
  # sdk500 直接编译 Classes/base500；其他版本先由脚本生成 generated/active。

  s.dependency 'Flutter'
  s.ios.deployment_target = '12.0'

  # 默认本地依赖：如需改为远程，请注释下一行并取消下方依赖注释
  s.vendored_frameworks = 'HyphenateChat.xcframework', 'ShengwangInfra_iOS/aosl.xcframework'

  # 远程依赖方案（替代 vendored_frameworks）：
  # s.dependency 'HyphenateChat', '>= 4.19.1'
  # s.dependency 'ShengwangChat_iOS', '>= 1.3.2'

end
