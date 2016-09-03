lib = 'ringcentral_sdk'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1
#require File.expand_path('../lib/ringcentral_sdk/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ringcentral_sdk'
  s.version     = version
  s.date        = '2016-09-04'
  s.summary     = 'RingCentral SDK - Ruby SDK for the RingCentral Connect Platform API'
  s.description = 'A Ruby SDK for the RingCentral Connect Platform API'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
  s.homepage    = 'https://github.com/grokify/'
  s.licenses    = ['MIT']
  s.files       = Dir['lib/**/**/*']
  s.files      += Dir['[A-Z]*'] + Dir['test/**/*']
  # s.files.reject! { |fn| fn.include? "CVS" }
  # s.required_ruby_version = '>= 1.8.7' # 1.8.7+ is tested
  s.add_dependency 'dotenv', '~> 2.1', '>= 2.1.0'
  s.add_dependency 'faraday', '~> 0.9', '>= 0.9'
  s.add_dependency 'faraday_middleware', '~> 0', '>= 0'
  s.add_dependency 'faraday_middleware-oauth2_refresh', '~> 0'
  s.add_dependency 'jsondoc', '~> 0.1', '>= 0.1.0'
  s.add_dependency 'logger'
  s.add_dependency 'mime', '~> 0.4', '>= 0.4.3'
  s.add_dependency 'mime-types', '~> 3.1' # >= 1.9 '~> 2.5', '>= 2.5'
  s.add_dependency 'mime_builder', '~> 0'
  s.add_dependency 'multi_json', '~> 1.3'
  s.add_dependency 'oauth2', '~> 1.0', '>= 1.0.0'
  s.add_dependency 'pubnub', '~> 3.8'
  s.add_dependency 'timers', '~> 4.1'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'test-unit'
end
