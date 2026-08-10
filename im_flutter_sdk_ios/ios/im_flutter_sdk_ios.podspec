#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
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

  s.source_files = 'Classes/merged/**/*'
  s.public_header_files = 'Classes/merged/**/*.h'
  # 注意：pod install 前先运行 im_flutter_sdk/scripts/merge_ios_sdk.sh 生成 Classes/merged/
  # （基线 base500 + 版本差异合并，同 Android 的 mergeWrapperSrc 机制）

  s.dependency 'Flutter'
  s.ios.deployment_target = '12.0'

  # 默认本地依赖：如需改为远程，请注释下一行并取消下方依赖注释
  s.vendored_frameworks = 'HyphenateChat.xcframework', 'ShengwangInfra_iOS/aosl.xcframework'

  # 远程依赖方案（替代 vendored_frameworks）：
  # s.dependency 'HyphenateChat', '>= 4.19.1'
  # s.dependency 'ShengwangChat_iOS', '>= 1.3.2'

end
