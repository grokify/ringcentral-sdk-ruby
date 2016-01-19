# Managing Call Queues - Setting DND Status

## Managing Call Queue Member Status

RingCentral Call Queues are a common way to assign responsibility for answering calls to an extension to multiple user extensions. The RingCentral API can be used enable and disable a user's Do Not Distrub (DND) status via the user extension's presence `dndStatus` property. This enables management of Call Queue members participation in answering calls from the queue.

Since this requires managing the extension presence on individual extensions, an administration extension authorization grant is necessary.

This is especially useful for scheduling applications that manage users that are on call for responding to inbound calls.

### Step 1: Create and Add User to a Call Queue

To create a call queue and add user extensions to the queue, use the RingCentral Online Account Portal as documented in [RingCentral Office Admin Guide](http://netstorage.ringcentral.com/guides/office_admin_guide.pdf).

### Step 2: Get List of Extension Ids for Call Queue Members

To update a user extension's `dndStatus` it is necessary to get the user's `extensionId` unique id property. There are a few possible approaches to this including the following two options:

1. Via Set of Explicit User Extension Numbers
2. Via Call Queue Extension Number Only

#### Step 2, Option 1: Via Set of Explicit User Extension Numbers

A user's `extensionNumber` is visible in the RingCentral Online Account Portal and is the extension number dialed to reach the user, e.g. 101, 102, etc. If you know the extension numbers you are interested in, you can query the `account/~/extension` end point for all extensions and then filter on the extension numbers of interest. This can be performed quickly as this endpoint allows retrieval of up to 1000 extensions per API request.

An easy way to implement this would be to configure a set of extension number values in the application which would then retrieve the extensions 1000 at a time to identify the matching extensions via the `extensionNumber` property.

#### Step 2, Option 2: Via Call Queue Extension Number Only

To more fully automate retrieval of Call Queue members, you can use the API to query the list of users that are members of a Call Queue by department extension number.

To do this, perform the following steps:

1. Retrieve all extensions using the `account/~/extension` endpoint
2. For each extension, retrieve the detailed information using the `account/~/extension/#/` endpoint

To retrieve all extensions, refer to the example in the ["Subscribing to All Extensions"](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/notifications/Subscriptions/#subscribing-to-all-extensions) example. Then for each extension, retrieve the extension endpoint which will include the `department` property.

```ruby
# Get department users
def get_department_users(rcsdk, department_extension_number)

  department_users = []

  response = rcsdk.client.get do |req|
    req.url 'account/~/extension?perPage=1000&status=Enabled&type=User'
  end

  users = response.body['records']
  users.each do |user|
    response = rcsdk.client.get do |req|
  	  req.url user['uri']
    end
    if response.body.has_key?('departments')
      response.body['departments'].each do |department|
        if department['extensionNumber'] == extension_number
          department_users.push(user)
          break
        end
      end
    end
  end

  return department_users
end

department_users = get_department_users(rcsdk, '201')
```

Note: since this approach will generate an API call per enabled user extension, your app should handle API rate limits. Two ways to do this are to wait for a 429 error and wait the number of seconds specified in the `Retry-After` header or to view your rate limits and build in a hard coded sleep between request.

### Step 3: Adjust User Call Queue Status via DND Status

After the queue has been created and users have been entered, queue member participation is determined by the user's `dndStatus` property, also known as Do Not Disturb (DND) status. The `dndStatus` property can be set to one of four values:

* `TakeAllCalls`
* `DoNotAcceptAnyCalls`
* `DoNotAcceptDepartmentCalls`
* `TakeDepartmentCallsOnly`

A Call Queue is known as a Department via the API so the `DoNotAcceptDepartmentCalls` status disables the user from recieving Call Queue calls (but allowing receipt of other calls) and the `TakeDepartmentCallsOnly` will enable the user to recieve only Call Queue calls. The other settings will affect call calls, including Call Queue calls.

Updating a user extension's `dndStatus` is done via the `presence` API endpoint described below. Performing this action in the RingCentral Online Account Portal is described in [KB Article 3770](http://success.ringcentral.com/articles/en_US/RC_Knowledge_Article/3770).

#### Step 3.1: Enable a User Extension for Call Queue Participation

To enable a user from participating in a Call Queue set the user extension's `dndStatus` to `TakeDepartmentCallsOnly` or `TakeAllCalls`

```ruby
# Set the user's dndStatus to TakeDepartmentCallsOnly or TakeAllCalls
response = rcsdk.client.put do |req|
  req.url 'account/111111/extension/222222/presence'
  req.headers['Content-Type'] = 'application/json'
  req.body  = {
    :dndStatus => 'TakeDepartmentCallsOnly'
  }
end
```

#### Step 3.2: Disable a User Extension for Call Queue Participation

To disable a user from participating in a Call Queue set the user extension's `dndStatus` to `DoNotAcceptDepartmentCalls` or `DoNotAcceptAnyCalls`

```ruby
# Set the user's dndStatus to DoNotAcceptDepartmentCalls or DoNotAcceptAnyCalls
response = rcsdk.client.put do |req|
  req.url 'account/111111/extension/222222/presence'
  req.headers['Content-Type'] = 'application/json'
  req.body  = {
    :dndStatus => 'DoNotAcceptDepartmentCalls'
  }
end
```
