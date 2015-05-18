Gem::Specification.new do |s|
  s.name        = 'ringcentral_sdk'
  s.version     = '0.0.3'
  s.date        = '2015-05-13'
  s.summary     = 'RingCentral SDK - Unofficial Ruby SDK for the RingCentral Connect Platform API'
  s.description = 'An unofficial Ruby SDK for the RingCentral Connect Platform API'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
  s.homepage    = 'https://github.com/grokify/'
  s.files       = [
    'CHANGELOG.md',
    'LICENSE.txt',
    'README.md',
    'Rakefile',
    'VERSION.txt',
    'lib/ringcentral_sdk.rb',
    'lib/ringcentral_sdk/helpers.rb',
    'lib/ringcentral_sdk/helpers/fax.rb',
    'lib/ringcentral_sdk/platform.rb',
    'lib/ringcentral_sdk/platform/auth.rb',
    'lib/ringcentral_sdk/platform/parser.rb',
    'lib/ringcentral_sdk/platform/platform.rb',
    'lib/ringcentral_sdk/sdk.rb',
    'test/test_setup.rb'
  ]
  s.add_dependency 'faraday', '~> 0.9', '>= 0.9'
  s.add_dependency 'faraday_middleware', '~> 0', '>= 0'
  s.add_dependency 'mime', '~> 0', '>= 0'
  s.add_dependency 'mime-types', '~> 2.5', '>= 2.5'
  s.add_dependency 'multi_json', '~> 0', '>= 0'
end