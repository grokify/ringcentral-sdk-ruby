require 'logger'
require 'pubnub'

module RingCentralSdk
  class PubnubFactory

    def initialize(use_mock=false)
      @_use_mock = use_mock
    end

    def pubnub(subscribe_key='', ssl_on=false, publish_key='', my_logger=nil)
      if @_use_mock
        raise 'PubNub Mock is not implemented'
      end

      my_logger = Logger.new(STDOUT) if my_logger.nil?

      pubnub = Pubnub.new(
        :subscribe_key    => subscribe_key.to_s,
        :publish_key      => publish_key.to_s,
        :error_callback   => lambda { |msg|
          puts "Error callback says: #{msg.inspect}"
        },
        :connect_callback => lambda { |msg|
          puts "CONNECTED: #{msg.inspect}"
        },
        :logger => my_logger
      )

      return pubnub
    end
  end
end