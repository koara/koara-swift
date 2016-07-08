Pod::Spec.new do |s|
  s.name             = 'koara'
  s.version          = '0.1.0'
  s.summary          = 'Koara parser written in Swift'



  s.homepage         = 'http://www.koara.io'
  s.license          = { :type => 'APACHE-2.0', :file => 'LICENSE' }
  s.author           = { 'Andy Van Den Heuvel' => 'andy.vandenheuvel@gmail.com' }
  s.source           = { :git => 'https://github.com/koara/koara-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'koara/Classes/**/*'
end
