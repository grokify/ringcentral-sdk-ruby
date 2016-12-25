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

# CoverPage is a example coverpage page builder class
class CoverPage
  def build_coverpage
    MIMEBuilder::Text.new(
      build_template_html,
      content_type: 'text/html',
      content_id_disable: true,
      is_attachment: true
    ).mime
  end

  def build_template_html
    template = build_template
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
    html
  end

  def build_template
    hbs = ENV['RC_DEMO_FAX_COVERPAGE_TEMPLATE'].strip
    raise "Coverpage Template Does Not Exist: #{hbs}" unless File.exist? hbs

    handlebars = Handlebars::Context.new
    template = handlebars.compile IO.read(hbs)
    template
  end
end

# Get the coverpage as a MIME::Media object to pass into
# Fax method as an file part
cover = CoverPage.new.build_coverpage

# Set coverIndex to 0 to remove standard template
# add MIME::Media object as first file attachment
res = client.messages.fax.create(
  to: ENV['RC_DEMO_FAX_TO'],
  coverIndex: 0,
  files: [cover, ENV['RC_DEMO_FAX_FILE']]
)
pp res.body

puts 'DONE'
