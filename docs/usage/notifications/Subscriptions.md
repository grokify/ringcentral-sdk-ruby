# Notifications: Subscription API

## FAQ

### How can I subscribe to all extensions

To subscribe to presence events for all extensions, create a set of event filters including filters for every extension, and then create a subscription including all the event filters. A presence event filter looks like the following `["/restapi/v1.0/account/~/extension/111111/presence"]`. A set of presence event filters looks like the following: `["/restapi/v1.0/account/~/extension/111111/presence". "/restapi/v1.0/account/~/extension/222222/presence"]`. A full set of extension ids can be retrieved via the extension endpoint: `/restapi/v1.0/account/~/extension`.