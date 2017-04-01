lib = 'ringcentral_sdk'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1
#require File.expand_path('../lib/ringcentral_sdk/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = lib
  s.version     = version
  s.date        = '2017-04-01'
  s.summary     = 'RingCentral SDK - Ruby SDK for the RingCentral Connect Platform API'
  s.description = 'A Ruby SDK for the RingCentral Connect Platform API'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
  s.homepage    = 'https://github.com/grokify/'
  s.licenses    = ['MIT']
  s.files       = Dir['lib/**/**/*']
  s.files      += Dir['[A-Z]*'] + Dir['test/**/*']
  # s.files.reject! { |fn| fn.include? "CVS" }

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'dotenv', '~> 2.1', '>= 2.1.0'
  s.add_dependency 'faraday', '~> 0', '>= 0'
  s.add_dependency 'faraday_middleware', '~> 0', '>= 0'
  s.add_dependency 'faraday_middleware-oauth2_refresh', '~> 0'
  s.add_dependency 'faraday_middleware-request-retry', '~> 0.1', '>= 0.1.0'
  s.add_dependency 'jsondoc', '~> 0.1', '>= 0.1.0'
  s.add_dependency 'logger', '~> 1'
  s.add_dependency 'mime', '~> 0.4', '>= 0.4.3'
  s.add_dependency 'mime-types', '~> 3.1' # >= 1.9 '~> 2.5', '>= 2.5'
  s.add_dependency 'mime_builder', '~> 0', '>= 0.0.4'
  s.add_dependency 'multi_json', '~> 1.3'
  s.add_dependency 'oauth2', '~> 1.0', '>= 1.0.0'
  s.add_dependency 'pubnub', '~> 4.0'

  s.add_development_dependency 'bundler', '~> 1'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'mocha', '~> 1'
  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'test-unit', '~> 3'
end
