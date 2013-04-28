Pod::Spec.new do |s|
  s.name         = "RTReader"
  s.version      = "0.0.1"
  s.summary      = "library used by reader."
  s.homepage     = "https://github.com/goodow/RTReader"
  s.author       = { "Larry Tin" => "dev@goodow.com" }
  s.source       = { :git => "https://github.com/goodow/RTReader.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '5.0'

  s.source_files = 'Classes/**/*.{h,m}'
  s.resources = 'Resources/**'

  s.requires_arc = true

  s.dependency 'jre_emul', '~> 0.7.2'
  s.dependency 'gtm-oauth2/Core', '~> 0.0.1'
  s.dependency 'gtm-oauth2/Core/Touch', '~> 0.0.1'
  s.dependency 'SBJson', '~> 3.2'
#  s.dependency 'MBProgressHUD', '~> 0.6'
#  s.dependency 'SVPullToRefresh', '~> 0.4.1'
#  s.dependency 'MWPhotoBrowser', '~> 1.0.1'
  s.dependency 'CocoaHTTPServer', '~> 2.3'

end
