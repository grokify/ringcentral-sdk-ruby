#!ruby

require 'ringcentral_sdk'
require 'pp'

config = RingCentralSdk::REST::Config.new
config.load_dotenv

client = RingCentralSdk::REST::Client.new(
  config.app.key,
  config.app.secret,
  config.app.server_url,
  {
    :username => config.user.username,
    :extension => config.user.extension,
    :password => config.user.password
  }
)

res = client.messages.fax.create(
  :to => config.env.data['RC_DEMO_FAX_TO'],
  :coverPageText => config.env.data['RC_DEMO_FAX_COVERPAGE_TEXT'],
  :files => [config.env.data['RC_DEMO_FAX_FILEPATH']]
)

pp res.body

puts "DONE"