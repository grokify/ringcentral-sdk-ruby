lib = 'ringcentral_sdk'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1
#require File.expand_path('../lib/ringcentral_sdk/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = lib
  s.version     = version
  s.date        = '2024-11-08'
  s.summary     = 'RingCentral SDK - Ruby SDK for the RingCentral Connect Platform API'
  s.description = 'A Ruby SDK for the RingCentral Connect Platform API'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
  s.homepage    = 'https://github.com/grokify/ringcentral-sdk-ruby'
  s.licenses    = ['MIT']
  s.files       = Dir['lib/**/**/*']
  s.files      += Dir['[A-Z]*'] + Dir['test/**/*']
  # s.files.reject! { |fn| fn.include? "CVS" }

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'dotenv', '~> 2.1', '>= 2.8.1'
  s.add_dependency 'faraday', '~> 1.10', '>= 1.10.3'
  s.add_dependency 'faraday_middleware', '~> 1.2', '>= 1.2.0'
  s.add_dependency 'faraday_middleware-oauth2_refresh', '~> 0.1.3', '>= 0.1.3'
  s.add_dependency 'faraday_middleware-request-retry', '~> 0.2.1', '>= 0.2.1'
  s.add_dependency 'jsondoc', '~> 0.1', '>= 0.1.4'
  s.add_dependency 'logger', '~> 1'
  s.add_dependency 'mime', '~> 0.4', '>= 0.4.4'
  s.add_dependency 'mime-types', '~> 3.4' # >= 1.9 '~> 2.5', '>= 2.5'
  s.add_dependency 'mime_builder', '~> 0.1', '>= 0.1.1'
  s.add_dependency 'multi_json', '~> 1.3'
  s.add_dependency 'oauth2', '~> 2.0', '>= 2.0.9'
  s.add_dependency 'pubnub', '~> 4.0', '>= 4.8.0'

  s.add_development_dependency 'bundler', '~> 2'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'mocha', '~> 2'
  s.add_development_dependency 'rake', '~> 13'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'test-unit', '~> 3'
end
