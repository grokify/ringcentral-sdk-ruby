# Managing Call Queues - Setting DND Status

## Managing Call Queue Member Status

RingCentral Call Queues are a common way to assign responsibility for answering calls to an extension to multiple user extensions. The RingCentral API can be used enable and disable a user's call queue status enabling you to manage active members of the queue.

This is especially useful for scheduling applications that manage users that are on call for responding to inbound calls.

### Create and Add User to a Call Queue

To create a call queue and add user extensions to the queue, use the RingCentral Online Account Portal as documented in [RingCentral Office Admin Guide](http://netstorage.ringcentral.com/guides/office_admin_guide.pdf).

### Adjust User Call Queue Status via DND Status

After the queue has been created and users have been entered, queue member participation is determined by the user's `dndStatus` property, also known as Do Not Disturb (DND) status. The `dndStatus` property can be set to one of four values:

* `TakeAllCalls`
* `DoNotAcceptAnyCalls`
* `DoNotAcceptDepartmentCalls`
* `TakeDepartmentCallsOnly`

A Call Queue is known as a Department via the API so the `DoNotAcceptDepartmentCalls` status disables the user from recieving Call Queue calls (but allowing receipt of other calls) and the `TakeDepartmentCallsOnly` will enable the user to recieve only Call Queue calls. The other settings will affect call calls, including Call Queue calls.

Updating a user extension's `dndStatus` is done via the `presence` API endpoint described below. Performing this action in the RingCentral Online Account Portal is described in [KB Article 3770](http://success.ringcentral.com/articles/en_US/RC_Knowledge_Article/3770).

#### Enable a User Extension for Call Queue Participation

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

#### Disable a User Extension for Call Queue Participation

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
