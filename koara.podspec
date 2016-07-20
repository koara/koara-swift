Pod::Spec.new do |s|
  s.name = 'Koara'
  s.version = '3.4.1'
  s.license = 'MIT'
  s.summary = 'Elegant HTTP Networking in Swift'
  s.homepage = 'https://github.com/Koara/Koara'
  s.social_media_url = 'http://twitter.com/KoaraSF'
  s.authors = { 'Koara Software Foundation' => 'info@Koara.org' }
  s.source = { :git => 'https://github.com/Koara/Koara.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/*.swift'
end
