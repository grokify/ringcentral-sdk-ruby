#!ruby

require 'multi_json'
require 'pp'
require 'ringcentral_sdk'

=begin 

RingCentralSdkBootstrap is code to load credentials simply from a JSON file.

The core part of the example is below.

=end 

class RingCentralSdkBootstrap

  def load_credentials(credentials_filepath, usage_string=nil)
    unless credentials_filepath.to_s.length>0
      raise usage_string.to_s
    end

    unless File.exists?(credentials_filepath.to_s)
      raise "Error: credentials file does not exist for: #{credentials_filepath}"
    end

    @credentials = MultiJson.decode(IO.read(credentials_filepath), :symbolize_keys=>true)

    @app_index = ARGV.shift
    @usr_index = ARGV.shift
    @app_index = @app_index.to_s =~ /^[0-9]+$/ ? @app_index.to_i : 0
    @usr_index = @usr_index.to_s =~ /^[0-9]+$/ ? @usr_index.to_i : 0
  end

  def get_sdk_with_token(env=:sandbox)
    credentials = @credentials
    app_index = @app_index
    resource_owner_index = @usr_index

    rcsdk = RingCentralSdk.new(
      credentials[env][:applications][app_index][:app_key],
      credentials[env][:applications][app_index][:app_secret],
      credentials[env][:api][:server]
    )

    rcsdk.authorize(
      credentials[env][:resource_owners][resource_owner_index][:username],
      credentials[env][:resource_owners][resource_owner_index][:extension],
      credentials[env][:resource_owners][resource_owner_index][:password],
    ) 

    return rcsdk
  end

end

boot = RingCentralSdkBootstrap.new
boot.load_credentials(ARGV.shift, 'Usage: subscription.rb path/to/credentials.json [app_index] [resource_owner_index]')
rcsdk = boot.get_sdk_with_token()

=begin 

get_all_extensions(rcsdk) retrieves all extensions.

=end 

# Get all account extensions
def get_all_extensions(rcsdk, account_id='~')
  extension_ids_map = {}
  extensions = []
  res = rcsdk.client.get do |req|
    req.url "/restapi/v1.0/account/#{account_id}/extension"
    req.params['page']    = 1
    req.params['perPage'] = 1000
    req.params['status']  = 'Enabled'
  end
  res.body['records'].each do |record|
    if !extension_ids_map.has_key?(record['id'])
      extensions.push record
      extension_ids_map[record['id']] = 1
    end
  end
  while res.body.has_key?('navigation') && res.body['navigation'].has_key?('nextPage')
    res = rcsdk.client.get do |req|
      req.url res.body['navigation']['nextPage']['uri']
    end
    res.body['records'].each do |record|
      if !extension_ids_map.has_key?(record['id'])
        extensions.push record
        extension_ids_map[record['id']] = 1
      end
    end
  end
  return extensions
end

# Create an array of event_filters from the array of extensions
def get_event_filters_for_extensions(extensions, account_id='~')
  event_filters = []

  extensions.each do |ext|
    if ext.has_key?('id')
      event_filter = "/restapi/v1.0/account/#{account_id}/extension/#{ext['id']}" +
        "/presence?detailedTelephonyState=true"
      event_filters.push event_filter
    end
  end
  return event_filters
end

# An example observer object
class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

def run_subscription(rcsdk, event_filters)
  # Create an observable subscription and add your observer
  sub = rcsdk.create_subscription()
  sub.subscribe(event_filters)

  # Add observer
  sub.add_observer(MyObserver.new())

  # Run until user clicks key to finish
  puts "Click any key to finish"
  stop_script = gets

  # End the subscription
  sub.destroy()
end

# Get all extensions
extensions = get_all_extensions(rcsdk)
# Get event filters for extensions
event_filters = get_event_filters_for_extensions(extensions)
# Make a subscription for all event_filters
run_subscription(rcsdk, event_filters)

puts "DONE"