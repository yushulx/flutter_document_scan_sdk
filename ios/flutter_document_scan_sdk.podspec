#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_document_scan_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_document_scan_sdk'
  s.version          = '0.3.0'
  s.summary          = 'A Flutter wrapper for Dynamsoft Document Normalizer, providing API for document edge detection and document rectification.'
  s.description      = <<-DESC
A Flutter wrapper for Dynamsoft Document Normalizer, providing API for document edge detection and document rectification.
                       DESC
  s.homepage         = 'https://github.com/yushulx/flutter_document_scan_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'yushulx' => 'lingxiao1002@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'DynamsoftCaptureVisionBundle', '2.6.1004'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
