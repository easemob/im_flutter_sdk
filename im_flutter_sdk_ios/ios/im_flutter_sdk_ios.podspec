#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'im_flutter_sdk_ios'
  s.version          = '4.14.0'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'HyphenateChat','4.14.0'
  # s.dependency 'ShengwangChat_iOS','1.3.2'
  s.ios.vendored_frameworks = 'framework/HyphenateChat.xcframework', 'framework/aosl.xcframework'
  s.ios.deployment_target = '12.0'

end

