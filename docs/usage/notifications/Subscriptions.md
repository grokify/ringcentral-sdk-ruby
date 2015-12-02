# Notifications: Subscription API

## FAQ

### How can I subscribe to all extensions

To subscribe to presence events for all extensions, create a set of event filters including filters for every extension, and then create a subscription including all the event filters. A presence event filter includes the accound id and extension id. Here is an example of a single presence event filter using the account id for the authorized session `["/restapi/v1.0/account/~/extension/111111/presence"]`. A set of presence event filters looks like the following: `["/restapi/v1.0/account/~/extension/111111/presence". "/restapi/v1.0/account/~/extension/222222/presence"]`. A full set of extension ids can be retrieved via the extension endpoint: `/restapi/v1.0/account/~/extension`. This has been tested with a single subscription API call and a set of over 2000 extensions.