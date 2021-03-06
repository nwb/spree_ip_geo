# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_ip_geo'
  s.version     = '3-4-stable'
  s.summary     = 'get coury id or code from its IP address with maxmind service.'
  s.description = 'This extension will get location information form Maxmind got the current request IP, and cache it in database. '
  s.required_ruby_version = '>= 2.2.0'

  s.author    = 'Albert Liu'
  s.email     = 'albertliu@naturalwellbeing.com'
  s.homepage  = 'http://www.naturalwellbeing.com'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  version = '~> 3-4-stable'
  #s.add_dependency 'spree_core'

end
