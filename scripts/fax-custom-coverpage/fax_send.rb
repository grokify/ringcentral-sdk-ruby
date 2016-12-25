#!ruby

require 'handlebars'
require 'ringcentral_sdk'
require 'pp'
require 'mime_builder'

# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold
client = RingCentralSdk::REST::Client.new do |config|
  config.dotenv = true
end

def build_coverpage
  hbs = ENV['RC_DEMO_FAX_COVERPAGE_TEMPLATE']
  unless File.exist? hbs
    raise "Coverpage Template Does Not Exist: " + hbs
  end

  handlebars = Handlebars::Context.new
  template = handlebars.compile IO.read(hbs)

  html = template.call(
    fax_date: DateTime.now.to_s,
    fax_pages: ENV['RC_DEMO_FAX_PAGES'],
    fax_to_name: ENV['RC_DEMO_FAX_TO_NAME'],
    fax_to_phone: ENV['RC_DEMO_FAX_TO'],
    fax_to_fax: ENV['RC_DEMO_FAX_TO'],
    fax_from_name: ENV['RC_DEMO_FAX_FROM_NAME'],
    fax_from_phone: ENV['RC_DEMO_FAX_FROM'],
    fax_from_fax: ENV['RC_DEMO_FAX_FROM'],
    fax_coverpage_text: ENV['RC_DEMO_FAX_COVERPAGE_TEXT']
  )

  builder = MIMEBuilder::Text.new \
    html,
    content_type: 'text/html',
    content_id_disable: true,
    is_attachment: true

  builder.mime
end

# Get the coverpage as a MIME::Media object to pass into
# Fax method as an file part
cover = build_coverpage

# Set coverIndex to 0 to remove standard template
# add MIME::Media object as first file attachment
res = client.messages.fax.create(
  to: ENV['RC_DEMO_FAX_TO'],
  coverIndex: 0,
  files: [cover, ENV['RC_DEMO_FAX_FILE']]
)
pp res.body

puts 'DONE'
