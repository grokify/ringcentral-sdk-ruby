require 'base64'
require 'logger'
require 'multi_json'
require 'observer'
require 'openssl'
require 'pubnub'

module RingCentralSdk
  module REST
    # Subscription class is an observerable class that represents
    # one RingCentral subscription using the PubNub transport via
    # the Subscription API
    class Subscription
      include Observable

      RENEW_HANDICAP = 60

      attr_reader :event_filters

      def initialize(client)
        @client = client
        @event_filters = []
        @_timeout = nil
        @_subscription = nil_subscription
        @_pubnub = nil
        @_logger_prefix = " -- #{self.class.name}: "
      end

      def nil_subscription
        {
          'eventFilters'    => [],
          'expirationTime'  => '', # 2014-03-12T19:54:35.613Z
          'expiresIn'       => 0,
          'deliveryMode'    => {
            'transportType' => 'PubNub',
            'encryption'    => false,
            'address'       => '',
            'subscriberKey' => '',
            'secretKey'     => ''
          },
          'id'              => '',
          'creationTime'    => '', # 2014-03-12T19:54:35.613Z
          'status'          => '', # Active
          'uri'             => ''
        }
      end

      def pubnub
        @_pubnub
      end

      def register(events = nil)
        alive? ? renew(events) : subscribe(events)
      end

      def add_events(events)
        raise 'Events is not an array.' unless events.is_a? Array
        @event_filters.push(events) unless events.empty?
      end

      def set_events(events)
        raise 'Events is not an array.' unless events.is_a? Array
        @event_filters = events
      end

      def subscribe(events = nil)
        set_events(events) if events.is_a? Array

        raise 'Events are undefined' unless @event_filters.is_a?(Array) && !@event_filters.empty?

        begin
          response = @client.http.post do |req|
            req.url 'subscription'
            req.headers['Content-Type'] = 'application/json'
            req.body = {
              eventFilters: @client.create_urls(@event_filters),
              deliveryMode: { transportType: 'PubNub' }
            }
          end
          set_subscription response.body
          _subscribe_at_pubnub
          changed
          notify_observers response
          return response
        rescue StandardError => e
          reset
          changed
          notify_observers(e)
          raise 'Subscribe HTTP Request Error: ' + e.to_s
        end
      end

      def renew(events = nil)
        set_events(events) if events.is_a? Array

        raise 'Subscription is not alive' unless alive?
        raise 'Events are undefined' if @event_filters.empty?
        _clear_timeout

        begin
          response = @client.http.post do |req|
            req.url uri_join(@_subscription['uri'], 'renew')
            req.headers['Content-Type'] = 'application/json'
          end

          set_subscription response.body
          changed
          notify_observers response

          return response
        rescue StandardError => e
          @client.config.logger.warn "RingCentralSdk::REST::Subscription: RENEW_ERROR #{e}"
          reset
          changed
          notify_observers e
          raise 'Renew HTTP Request Error'
        end
      end

      def remove
        raise 'Subscription is not alive' unless alive?

        begin
          response = @client.http.delete do |req|
            req.url 'subscription/' + @_subscription['id'].to_s
          end
          reset
          changed
          notify_observers response.body
          return response
        rescue StandardError => e
          reset
          changed
          notify_observers e
        end
      end

      def alive?
        s = @_subscription
        if
          (s.key?('deliveryMode') && s['deliveryMode']) \
          && (s['deliveryMode'].key?('subscriberKey') && s['deliveryMode']['subscriberKey']) \
          && (
            s['deliveryMode'].key?('address') \
            && !s['deliveryMode']['address'].nil? \
            && !s['deliveryMode']['address'].empty?
          )
          return true
        end
        false
      end

      def subscription
        @_subscription
      end

      def set_subscription(data)
        _clear_timeout
        @_subscription = data
        _set_timeout
      end

      def reset
        _clear_timeout
        _unsubscribe_at_pubnub
        @_subscription = nil_subscription
      end

      def destroy
        reset
      end

      def _subscribe_at_pubnub
        raise 'Subscription is not alive' unless alive?

        s_key = @_subscription['deliveryMode']['subscriberKey']

        @_pubnub = new_pubnub(s_key, false, '')

        callback = Pubnub::SubscribeCallback.new(
          message: ->(envelope) {
            @client.config.logger.debug "MESSAGE: #{envelope.result[:data]}"
            _notify envelope.result[:data][:message]
            changed
          },
          presence: ->(envelope) {
            @client.config.logger.info "PRESENCE: #{envelope.result[:data]}"
          },
          status: lambda do |envelope|
            @client.config.logger.info "\n\n\n#{envelope.status}\n\n\n"
            if envelope.error?
              @client.config.logger.info "ERROR! #{envelope.status[:category]}"
            elsif envelope.status[:last_timetoken] == 0 # Connected!
              @client.config.logger.info('CONNECTED!')
            end
          end
        )

        @_pubnub.add_listener callback: callback, name: :ringcentral

        @_pubnub.subscribe(
          channels: @_subscription['deliveryMode']['address']
        )
        @client.config.logger.debug('SUBSCRIBED')
      end

      def _notify(message)
        count = count_observers
        @client.config.logger.debug("RingCentralSdk::REST::Subscription NOTIFYING '#{count}' observers")

        message = _decrypt message
        changed
        notify_observers message
      end

      def _decrypt(message)
        unless alive?
          raise 'Subscription is not alive'
        end

        if _encrypted?
          delivery_mode = @_subscription['deliveryMode']

          cipher = OpenSSL::Cipher::AES.new(128, :ECB)
          cipher.decrypt
          cipher.key = Base64.decode64(delivery_mode['encryptionKey'].to_s)

          ciphertext = Base64.decode64(message)
          plaintext = cipher.update(ciphertext) + cipher.final

          message = MultiJson.decode(plaintext, symbolize_keys: false)
        end

        message
      end

      def _encrypted?
        delivery_mode = @_subscription['deliveryMode']
        is_encrypted  = delivery_mode.key?('encryption') \
          && delivery_mode['encryption'] \
          && delivery_mode.key?('encryptionKey') \
          && delivery_mode['encryptionKey']
        is_encrypted
      end

      def _unsubscribe_at_pubnub
        if @_pubnub && alive?
          @_pubnub.unsubscribe(channel: @_subscription['deliveryMode']['address']) do |envelope|
            puts envelope.status
          end
        end
      end

      def _set_timeout
        _clear_timeout

        time_to_expiration = @_subscription['expiresIn'] - RENEW_HANDICAP

        @_timeout = Thread.new do
          sleep time_to_expiration
          renew
        end
      end

      def _clear_timeout
        @_timeout.exit if @_timeout.is_a?(Thread) && @_timeout.status == 'sleep'
        @_timeout = nil
      end

      def uri_join(*args)
        url = args.join('/').gsub(%r{/+}, '/')
        url.gsub(%r{^(https?:/)}i, '\1/')
      end

      def new_pubnub(subscribe_key = '', ssl_on = false, publish_key = '', my_logger = nil)
        Pubnub.new(
          subscribe_key: subscribe_key.to_s,
          publish_key: publish_key.to_s
        )
      end
    end
  end
end
