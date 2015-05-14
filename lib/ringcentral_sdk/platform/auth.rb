module RingCentralSdk::Platform
	class Auth
		attr_accessor :data
		attr_accessor :remember

		attr_reader   :access_token

		def initialize()
			@data     = nil
			@remember = nil
		end
		def set_data(data={})
			return unless data.is_a?(Hash)

			@access_token = data["access_token"] ? data["access_token"] : ''
			@token_type   = data["token_type"]   ? data["token_type"]   : ''

		end
	end
end