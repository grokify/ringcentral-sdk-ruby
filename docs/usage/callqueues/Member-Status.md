# Managing Call Queues - Updating Member Status

## Overview

RingCentral Call Queues are a common way to assign responsibility for answering calls to an extension to multiple users.

The RingCentral API can be used to automate the scheduling of which members are currently active and inactive on the call queue, a useful feature when managing on call users via an external application. This can be done by updating the status of a queue member's Do Not Disturb (DND) status via the user extension's presence `dndStatus` property as described here.

Since this requires managing the extension presence on individual extensions, an administration extension authorization grant is necessary.

## Synopsis

The following presents useful code for managing call queue member status given a call queue extension number with existing members. The Details section below discusses each of these steps in more detail and identifies the code being used in the SDK for reference.

```ruby
# Instantiate client SDK and authorize as administrator
rcapi = RingCentralSdk.new(...)
rcapi.login(...) # can be ROPC grant or authorization code grant

# Retrieve a Call Queue Extension by Extension Number to Store in Your App
call_queue_extension_number = 201

cache = RingCentralSdk::Cache::Extensions.new(rcapi)
cache.retrieve_all()

call_queue = cache.get_extension_by_number(call_queue_extension_number)

# Retrieve Call Queue Members by Call Queue Id to Map to Your User Database
call_queue_members = cache.get_department_members(call_queue['id'])

# Enable and Disable Call Queue Member Status
extension_id = call_queue_members[0]['id']

extension_presence = RingCentralSdk::Helpers::ExtensionPresence.new(rcapi, extension_id)

## Enable Call Queue calls
extension_presence.enable_department_calls()

## Enable Call Queue calls
extension_presence.disable_department_calls()
```

## Details

Integration with a third-party scheduling service can involve the following steps:

1. Create and Add Users to a Call Queue
2. Configure the RingCentral Call Queue in the Scheduling Application
3. Updating User Call Queue Status

These steps are described below including general steps as well as code using the Ruby SDK. To see how the general steps are implemented, refer to the classes referenced below in [GitHub](https://github.com/grokify/ringcentral-sdk-ruby).

### Step 1: Create and Add Users to a Call Queue

Using the [RingCentral Online Account Portal](https://service.ringcentral.com), create a call queue and add user extensions to the queue as documented in [RingCentral Office Admin Guide](http://netstorage.ringcentral.com/guides/office_admin_guide.pdf).

### Step 2: Configure the RingCentral Call Queue in the Scheduling Application

Now that the extension is configured in RingCentral, build the application so an end-user can configure the call queue in the scheduling application. To this:

1. Create a RingCentral call queue object
2. Retrieve the call queue members
3. Map queue members to your user objects

#### Step 2.1: Create a RingCentral call queue object

Create an object to represent a RingCentral call queue object in your application which will be mapped to a RingCentral call queue extension and member user extensions. This should include the call queue extension's `id` and the `extensionNumber`. The extension `id` is a API level identifier for further API calls while the `extensionNumber` is used in the RingCentral Online Account Portal and will be familiar to and known by end users.

The retieve the call queue extension information to store with your app.

The above is implemented in `RingCentralSdk::Cache::Extensions` ([lib/ringcentral_sdk/cache/extensions.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/lib/ringcentral_sdk/cache/extensions.rb)) and can be used as follows:

```ruby
# Retrieve a Call Queue Extension by Extension Number
call_queue_extension_number = 201

cache = RingCentralSdk::Cache::Extensions.new(rcapi)
cache.retrieve_all()

call_queue = cache.get_extension_by_number(call_queue_extension_number)
```

#### Step 2.2. Retrieve the call queue members

In an end-user application, allow the user to enter call queue's extension number and then retrieve the call queue member information.

To perform these steps using the RingCentral API, perform the following steps:

1. Locate the call queue extension id by retrieving an extension list from the API and performing a client-side filter on `extensionNumber`. At the API, this can either be full extension list or filtered on `type=Department` for call queue extensions.
2. Call the `department/members` API endpoint to retrieve a list of member extension ids and extension numbers
3. Call the extension API endpoint to retrieve the full information for each call queue member

The above is implemented in `RingCentralSdk::Cache::Extensions` ([lib/ringcentral_sdk/cache/extensions.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/lib/ringcentral_sdk/cache/extensions.rb)) and can be used as follows:

```ruby
# Retrieve Call Queue Members by Call Queue Id
# Call cache.retrieve_all() first as shown above
call_queue_members = cache.get_department_members(call_queue['id'])
```

#### Step 2.3: Map queue members to your user objects

Now that you have the call queue member extension info, store this with your user information so you can use the call queue member extension ids to enable and disable call queue members as appropriate. The call queue member extension information also includes information such as name, extension number, etc. that can be displayed in the application for improved UX.

### Step 3: Updating User Call Queue Status

After the queue has been created and users have been entered, queue member participation is determined by the user's `dndStatus` property, also known as Do Not Disturb (DND) status. The `dndStatus` property can be set to one of four values:

dndStatus | Accept Department Calls | Accept Non-Department Calls
----------|-------------------------|----------------------------
`TakeAllCalls` | yes | yes
`DoNotAcceptAnyCalls` | no | no
`DoNotAcceptDepartmentCalls` | no | yes
`TakeDepartmentCallsOnly` | yes | no

A Call Queue is known as a Department via the API so the `DoNotAcceptDepartmentCalls` status disables the user from recieving Call Queue calls (but allowing receipt of other calls) and the `TakeDepartmentCallsOnly` will enable the user to recieve only Call Queue calls. The other settings will affect call calls, including Call Queue calls.

Updating a user extension's `dndStatus` is done via the `presence` API endpoint described below. Performing this action in the RingCentral Online Account Portal is described in [KB Article 3770](http://success.ringcentral.com/articles/en_US/RC_Knowledge_Article/3770).

#### Step 3.1: Enable a User Extension for Call Queue Calls

To enable a user for Call Queue calls, ensure that the extension's `dndStatus` is accepting department calls per the table above. This involves the following steps:

1. Retrieve the extension's current presence `dndStatus` using the `extension/presence` endpoint
2. Check to see if the extension's `dndStatus` includes department (call queue) calls
3. If the presence does not include department calls, update the `extension/presence` endpoint with the appropriate new status

The above is implemented in `RingCentralSdk::Helpers::ExtensionPresence` ([lib/ringcentral_sdk/helpers/extension_presence.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/lib/ringcentral_sdk/helpers/extension_presence.rb)) and can be used as follows:

```ruby
extension_id = 111111

extension_presence = RingCentralSdk::Helpers::ExtensionPresence.new(rcapi, extension_id)
extension_presence.enable_department_calls()
```

#### Step 3.2: Disable a User Extension for Call Queue Calls

To disable a user for Call Queue calls, ensure that the extension's `dndStatus` is not accepting department calls per the table above. This involves the following steps:

1. Retrieve the extension's current presence `dndStatus` using the `extension/presence` endpoint
2. Check to see if the extension's `dndStatus` excludes department (call queue) calls
3. If the presence includes department calls, update the `extension/presence` endpoint with the appropriate new status

The above is implemented in `RingCentralSdk::Helpers::ExtensionPresence` ([lib/ringcentral_sdk/helpers/extension_presence.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/lib/ringcentral_sdk/helpers/extension_presence.rb)) and can be used as follows:

```ruby
extension_id = 111111

extension_presence = RingCentralSdk::Helpers::ExtensionPresence.new(rcapi, extension_id)
extension_presence.disable_department_calls()
```
