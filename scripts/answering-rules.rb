#!ruby

require 'dotenv'
require 'ringcentral_sdk'
require 'pp'

puts ENV['ENV_PATH']

envPath = ENV['ENV_PATH'] || '.env'
# Set your credentials in the .env file
# Use the rc_config_sample.env.txt file as a scaffold

#client = RingCentralSdk::REST::Client.new do |config|
#  config.load_env = true
#end

puts envPath
Dotenv.load envPath

puts ENV['RINGCENTRAL_USERNAME']
puts ENV['RINGCENTRAL_SERVER_URL']

def EnvVal(envVar)
  envVar = envVar + '_2'
  ENV[envVar]
end

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = EnvVal('RINGCENTRAL_SERVER_URL')
  config.app_key    = EnvVal('RINGCENTRAL_CLIENT_ID')
  config.app_secret = EnvVal('RINGCENTRAL_CLIENT_SECRET')
  config.username   = EnvVal('RINGCENTRAL_USERNAME')
  config.extension  = EnvVal('RINGCENTRAL_EXTENSION')
  config.password   = EnvVal('RINGCENTRAL_PASSWORD')
end

def getForwardingNumbers(client, accountId, extensionId)
  client.http.get "account/#{accountId}/extension/#{extensionId}/forwarding-number"
end

def delAnsweringRule(client, accountId, extensionId, answeringRuleId)
  client.http.delete "account/#{accountId}/extension/#{extensionId}/answering-rule/#{answeringRuleId}"
end

def getAnsweringRules(client, accountId, extensionId)
  client.http.get "account/#{accountId}/extension/#{extensionId}/answering-rule"
end

def getAnsweringRule(client, accountId, extensionId, answeringRuleId)
  client.http.get "account/#{accountId}/extension/#{extensionId}/answering-rule/#{answeringRuleId}"
end

# Business Hours Rule - On Routing Extension
# Routing Extension, Set to Final Default Extension ID
def updateAnsweringRuleOnRoutingExt(client, accountId, extensionId, answeringRuleId, forwardingNumberId)
  body = {
    'enabled' => true,
    'forwarding' => {
      'notifyMySoftPhones' => true,
      'softPhonesRingCount' => 5,
      'ringingMode' => 'Sequentially',
      'rules': [{
        'index': 1,
        'ringCount': 3,
        'forwardingNumbers' => [{
          'id' => forwardingNumberId
        }],
      }]
    }
  }
  client.http.put do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/answering-rule/#{answeringRuleId}"
    req.headers['Content-Type'] = 'application/json'
    req.body = body
  end
end

def updateAnsweringRuleOnInboundExt(client, accountId, extensionId, answeringRuleId, selfFwdNumId, routingFwdNumId)
  body = {
    'enabled'    => true,
    'forwarding' => {
      'notifyMySoftPhones'    => true,
      'notifyAdminSoftPhones' => false,
      'softPhonesRingCount'   => 5,
      'ringingMode' => 'Sequentially',
      'rules': [
        {
          'index': 1,
          'ringCount': 3,
          'forwardingNumbers' => [{'id' => selfFwdNumId}]
        },
        {
          'index': 2,
          'ringCount': 3,
          'forwardingNumbers' => [{'id' => routingFwdNumId}]
        },
      ]
    }
  }
  client.http.put do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/answering-rule/#{answeringRuleId}"
    req.headers['Content-Type'] = 'application/json'
    req.body = body
  end
end

def createForwardingNumber(client, accountId, extensionId, phoneNumber, label)
  client.http.post do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/forwarding-number"
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      'phoneNumber' => phoneNumber,
      'label' => label
    }
  end
end

def createCustomCallHandlingRule(client, accountId, extensionId, ruleName, callerIds, fwdId)
  body = {
    'name'    =>  ruleName,
    'enabled' => true,
    'callers' => [],
    'forwarding' => {
      'notifyMySoftPhones'    => true,
      'notifyAdminSoftPhones' => false,
      'softPhonesRingCount'   => 5,
      'ringingMode' => 'Sequentially',
      'rules': [
        {
          'index': 1,
          'ringCount': 3,
          'forwardingNumbers' => [{'id' => fwdId}]
        },
      ]
    }
  }
  callerIds.each do |callerId|
    body['callers'].push({'callerId' => callerId})
  end
  client.http.post do |req|
    req.url "account/#{accountId}/extension/#{extensionId}/answering-rule"
    req.headers['Content-Type'] = 'application/json'
    req.body = body
  end
end

def handleResponse(res)
  puts res.status
  pp res.body
end

#handleResponse getForwardingNumbers(client,'~','~')
handleResponse getAnsweringRules(client,'~','~')
#handleResponse getAnsweringRule(client,'~','~', 'business-hours-rule')
#handleResponse getAnsweringRule(client,'~','~', '12345678')
#handleResponse delAnsweringRule(client,'~','~', '12345678')

#handleResponse createCustomCallHandlingRule(client,'~','~','Custom +16505550100', ['+16505550100'], 12345678)
#delRules = [12345678,123456789]

if 1==1
  res = getAnsweringRules(client,'~','~')
  res.body['records'].each do |rec|
  	if rec['type'] == 'Custom'
      puts rec['id']
      pp rec
      handleResponse delAnsweringRule(client,'~','~', rec['id'])
    end
  end
end

if 1==0
    handleResponse createForwardingNumber(client, '~', '~',
        ENV['IVRDEMO_DEFAULT_FINAL_EXTENSION_DIRECT_NUMBER'],
        ENV['IVRDEMO_DEFAULT_FINAL_EXTENSION_LABEL'])

    handleResponse createForwardingNumber(client, '~', '~',
        ENV['IVRDEMO_SPECIAL_FINAL_EXTENSION_DIRECT_NUMBER'],
        ENV['IVRDEMO_SPECIAL_FINAL_EXTENSION_LABEL'])
end

if 1==0
    handleResponse createForwardingNumber(client, '~', '~',
        ENV['IVRDEMO_ROUTING_EXTENSION_DIRECT_NUMBER'],
        ENV['IVRDEMO_ROUTING_EXTENSION_LABEL'])
end

if 1==0
    handleResponse updateAnsweringRuleOnRoutingExt(client, '~', '~', 'business-hours-rule', 12345678)
end

puts 'DONE'
