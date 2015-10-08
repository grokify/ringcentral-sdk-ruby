require File.expand_path('../lib/ringcentral_sdk/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ringcentral_sdk'
  s.version     = RingCentralSdk::VERSION
  s.date        = '2015-10-07'
  s.summary     = 'RingCentral SDK - Ruby SDK for the RingCentral Connect Platform API'
  s.description = 'A Ruby SDK for the RingCentral Connect Platform API'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
  s.homepage    = 'https://github.com/grokify/'
  s.licenses    = ['MIT']
  s.files       = [
    'CHANGELOG.md',
    'LICENSE.txt',
    'README.md',
    'Rakefile',
    'VERSION.txt',
    'lib/ringcentral_sdk.rb',
    'lib/ringcentral_sdk/helpers.rb',
    'lib/ringcentral_sdk/helpers/fax.rb',
    'lib/ringcentral_sdk/helpers/inflator.rb',
    'lib/ringcentral_sdk/helpers/inflator/contact_info.rb',
    'lib/ringcentral_sdk/helpers/request.rb',
    'lib/ringcentral_sdk/platform.rb',
    'lib/ringcentral_sdk/platform/platform.rb',
    'lib/ringcentral_sdk/pubnub_factory.rb',
    'lib/ringcentral_sdk/sdk.rb',
    'lib/ringcentral_sdk/subscription.rb',
    'lib/ringcentral_sdk/version.rb',
    'test/test_setup.rb'
  ]
  # s.required_ruby_version = '>= 1.8.7' # 1.8.7+ is tested
  s.add_dependency 'faraday', '~> 0.9', '>= 0.9'
  s.add_dependency 'faraday_middleware', '~> 0', '>= 0'
  s.add_dependency 'faraday_middleware-oauth2_refresh', '>= 0'
  s.add_dependency 'mime', '>= 0'
  s.add_dependency 'mime-types', '>= 1.25' # >= 1.9 '~> 2.5', '>= 2.5'
  s.add_dependency 'multi_json', '>= 0'
  s.add_dependency 'oauth2', '>= 0'
  s.add_dependency 'pubnub', '~> 3.7.3'
  s.add_dependency 'test-unit', '>= 0'
  s.add_dependency 'timers', '>= 0'
end
