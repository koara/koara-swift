Pod::Spec.new do |s|
  s.name         = 'Koara'
  s.version      = '0.15.0'
  s.summary      = 'Koara parser written in Swift'
  s.description  = 'Koara is a modular lightweight markup language. The developer decides which parts of the syntax are allowed to be parsed. The rest will render as plain text.'
  s.homepage     = 'https://www.codeaddslife.com/koara'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author       = 'Andy Van den Heuvel'
  s.source = { :git => 'https://github.com/koara/koara-swift.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = "Source/**/*.{swift,h,m,c}"
end