# Fax Messages

## Faxing a Text Message

## Faxing a PDF or TIFF

### Faxing a PDF or TIFF

### Faxing a PDF or TIFF Using Base64 Encoding

```ruby
fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  { :account_id => '~', :extension_id => '~' }, # Can be nil or {} for defaults '~'
  {
    # phone numbers are in E.164 format with or without leading '+'
    :to            => [{ :phoneNumber => '+16505551212' }],
    :faxResolution => 'High',
    :coverPageText => 'RingCentral fax PDF example using Ruby!'
  },
  :file_name     => '/path/to/my_file.pdf'
  :base64_encode => true
)
```