Pod::Spec.new do |s|
  s.name = 'Koara'
  s.version = '0.1.0'
  s.license = 'Apache-2.0'
  s.summary = 'Koara parser written in Swift'
  s.homepage = 'http://www.koara.io'
  s.authors = { 'Andy Van Den Heuvel' => 'andy.vandenheuvel@gmail.com' }
  s.source = { :git => 'https://github.com/koara/koara-swift.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/*.swift'
end