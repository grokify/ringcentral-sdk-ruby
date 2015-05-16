require 'time'

module RingCentralSdk::Platform
  class Auth
    attr_accessor :data
    attr_accessor :remember

    attr_reader   :access_token
    attr_reader   :token_type

    def initialize()
      @data     = nil
      @remember = nil
    end
    def set_data(data={})
      return unless data.is_a?(Hash)

      @access_token = data["access_token"] ? data["access_token"] : ''
      @token_type   = data["token_type"]   ? data["token_type"]   : ''

    end

    def is_access_token_valid()
      return _is_token_date_valid(@data[:expire_time])
    end

    def _is_token_date_valid(token_date)
      return token_date > Time.now
    end

  end
end