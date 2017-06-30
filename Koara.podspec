Pod::Spec.new do |s|
  s.name         = "Koara"
  s.version      = "0.13.0"
  s.summary      = "Koara parser written in Swift"
  s.homepage     = 'https://codeaddslife.com/koara'
  s.authors      = { "Andy Van Den Heuvel" => "andy.vandenheuvel@gmail.com" }
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.source       = { :git => "https://github.com/koara/koara-swift.git", :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/**/*.swift'
end
