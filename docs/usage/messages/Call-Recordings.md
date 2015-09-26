# Call Recordings

Call recordings are stored on the RingCentral servers and can be retrieved using the API for download and streaming playback.

## Retrieving Call Log Records with Recordings

Calls with recordings can be identified using the Call Log API and locating records with the `RecordingInfo` object.

The below example uses a filter to locate voice calls with call recordings and then downloads the file for each recording.

```ruby
rcsdk = RingCentralSdk::Sdk.new(
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
rcsdk.platform.authorize('myUsername', 'myExtension', 'myPassword')

response = rcsdk.platform.client.get do |req|
  params = {
    :type =>  'Voice',
    :withRecording => true
  }
  req.url 'account/~/extension/~/call-log', params
end

response.body['records'].each do |record|
  response_file = rcsdk.platform.client.get do |req|
    req.url record['recording']['contentUri']
  end
  filename = 'recording_' + record['id'] + '.mp3'
  File.open(filename, 'wb') { |fp| fp.write(response_file.body) }
end
```