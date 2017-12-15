Pod::Spec.new do |s|
  s.name         = "StarscreamSocketIO"
  s.version      = "8.0.4"
  s.summary      = "A fork of a conforming WebSocket RFC 6455 client library in Swift for iOS and OSX."
  s.homepage     = "https://github.com/nuclearace/Starscream"
  s.license      = 'Apache License, Version 2.0'
  s.author       = {'Dalton Cherry' => 'http://daltoniam.com', 'Austin Cherry' => 'http://austincherry.me'}
  s.source       = { :git => 'https://github.com/nuclearace/Starscream.git',  :tag => "8.0.4"}
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'Source/*.swift'
  s.requires_arc = true
  s.libraries    = 'z'
  s.pod_target_xcconfig = {
  'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/StarscreamSocketIO/zlib',
  'SWIFT_VERSION' => '3.1'
  }
  s.preserve_paths = 'zlib/*'
end
