require './test/test_base.rb'

require 'faraday'
require 'oauth2'
=begin
class RingCentralSdkRESTConfigTest < Test::Unit::TestCase
  def setup
    @config = RingCentralSdk::REST::Config.new.load_dotenv
  end

  def use_later_test_main
    @config = RingCentralSdk::REST::Config.new.load_dotenv
    assert_equal 'myAppKey', @config.app.key
    assert_equal 'myAppSecret', @config.app.secret
    assert_equal 'myRcApiServerUrl', @config.app.server_url
    assert_equal 'myRcApiRedirectUrl', @config.app.redirect_url

    assert_equal 'myUsername', @config.user.username
    assert_equal 'myExtension', @config.user.extension
    assert_equal 'myPassword', @config.user.password

    assert_equal 'demoFaxToPhoneNumber', @config.env.data['RC_DEMO_FAX_TO']

    @config.user.nilify
    assert_equal '', @config.user.username
    assert_equal '', @config.user.extension
    assert_equal '', @config.user.password
  end
end
=end