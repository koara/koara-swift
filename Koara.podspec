Pod::Spec.new do |s|
  s.name = 'Koara'
  s.version = '0.0.1'
  s.license = 'Apache 2.0'
  s.summary = 'Koara parser written in Swift'
  s.homepage = 'https://github.com/koara/koara-swift'
  s.source = { :git => 'https://github.com/koara/koara-swift.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/*.swift'
end