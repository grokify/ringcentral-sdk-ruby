FaxOut API
==========

This page is downloaded from: https://service.ringcentral.com/faxoutapi/

Send Fax Web API is based on a single HTTP POST request with multipart/form-data body through which un-rendered fax data is passed to the web. An appropriate response containing request execution result should be returned back to requesting application. The response only says if the fax has been accepted or not. Sending status will be provided to user by email. HTTPS protocol is proposed for using with Send Fax Web API for better security.

ASP script located at:

`https://service.ringcentral.com/faxapi.asp`

## 1. Request format

List of recipients, documents, send options etc are considered as separate multipart/form-data body-parts of the request body.

| Field | Description | Value |
| Username | Description: | Represents user phone number and extension |
| Username | Possible values: | |
| Username | Format | ASCII string in full format that includes the country code <phonenumber>[*<extension>.]. If a user uses master account then extension part is not passed. |
| Username | Number of occurrences: one |
Password	
Description:	Represents user password
Possible values:	
Format:	ASCII string
Number of occurrences:	no more then one
Recipient	
Description:	Represents single fax recipient and consists of pair phone number and name
Possible values:	Recipient number is mandatory, recipient name is optional.
Format:	ASCII string, passed as in following format: <recipient number>|<recipient name> ("|" character is a separator)
Number of occurrences:	more or equal then one
Coverpage	
Description:	Name of fax cover page.
Possible values:	-	None. Cover page is not used
-	Default. Default cover page
-	<Name> - name of a cover page. Should correspond to one of the cover pages installed on rendering server.
If parameter is not specified or its value is empty then default cover page will be used. There should only one coverpage parameter in request.
Format:	ASCII string
Number of occurrences:	no more then one
Coverpagetext	
Description:	Represents text printed on fax cover page.
Possible values:	
Format:	ASCII string.
Number of occurrences:	no more then one
Resolution	
Description:	Represents resolution in which fax will be sent to recipients.
Possible values:	-	Low
-	High
Format:	ASCII string.
Number of occurrences:	no more then one
Sendtime	
Description:	Schedule time.
Possible values:	GMT time in format dd:mm:yy hh:mm If parameter is not specified or invalid then send time is considered to current time so fax will be send as soon as possible.
Format:	ASCII string.
Number of occurrences:	no more then one
Attachment	
Description:	Document to be faxed.
Possible values:	Original document file name must be passed in the filename field of the body-part header.
Format:	Binary stream.
Number of occurrences:	any.

## 2. Response format

Response returns request processing status as an integer value. Possible value can be on of the following:

* 0 - Successful
* 1 - Authorization failed
* 2 - Faxing is prohibited for the account
* 3 - No recipients specified
* 4 - No fax data specified
* 5 - Generic error

**Request body example**

```mime
Content-Type: multipart/form-data; boundary=---------------------------7d54b1fee05aa

-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Username"

15556090455
-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Password"

qwerty
-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Attachment"; filename="C:\example.doc" 
<Document content is here>
-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Recipient"

5556465589|John Doe
-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Recipient"

5555568552|John Smith
-----------------------------7d54b1fee05aa
Content-Disposition: form-data; name="Coverpagetext"

This is a test fax from web
-----------------------------7d54b1fee05aa--
```

**Response**
0
