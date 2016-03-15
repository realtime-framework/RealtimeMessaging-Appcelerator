# ORTC Module

## Description

This module allows to integrate ORTC service with Titanium Mobile applications.

The ORTC (Open Real-Time Connectivity) was developed to add a layer of abstraction to real-time full-duplex web communications platforms by making real-time web applications independent of those platforms.

ORTC provides a standard software API (Application Programming Interface) for sending and receiving data in real-time over the web.

## Installation

For information how to use Titanium Modules, please follow the guide [here](http://wiki.appcelerator.org/display/tis/Using+Titanium+Modules).

## Accessing the ORTC Module

To access this module from JavaScript, you would do the following:

	var ORTC = require("co.realtime.ortc");

The ORTC variable is a reference to the Module object.	

## Reference

### Properties

#### clusterUrl
The cluster server URL

Example:

	ORTC.clusterUrl = 'http://ortc-developers.realtime.co/server/2.1';
#### url
The server URL

Example:

	ORTC.url = 'http://ortc-developers-euwest1-S0001.realtime.co/server/2.1';
#### connectionMetadata
The client connection metadata

Example:

	ORTC.connectionMetadata = 'Titanium Client';
#### announcementSubchannel
The client announcement subchannel

Example:

	ORTC.announcementSubchannel = 'announcementSubchannel';
#### sessionId (readonly)
The client session identifier

Example:

	alert(ORTC.sessionId);

### Events

#### onException
Event fired whenever exception occurs.
The event parameter passed on the callback function has defined following property:
- **info** [string]: description of the exception

Example:

	ORTC.addEventListener('onException', function(e) {	
		alert('Exception: '+e.info);
	});

#### onConnected
Event fired whenever module connects.

Example:

	ORTC.addEventListener('onConnected', function(e) {
		alert('Connected');
	});

#### onDisconnected
Event fired whenever module disconnects.

Example:

	ORTC.addEventListener('onDisconnected', function(e) {
		alert('Disconnected');
	});

#### onReconnected
Event fired whenever module reconnects.

Example:

	ORTC.addEventListener('onReconnected', function(e) {
		alert('Reconnected');
	});

#### onReconnecting
Event fired whenever module connects.

Example:

	ORTC.addEventListener('onReconnecting', function(e) {
		alert('Reconnecting');
	});

#### onSubscribed
Event fired when module subscribes to a channel.
The event parameter passed on the callback function has defined following property:
- **channel** [string]: the channel name

Example:

	ORTC.addEventListener('onSubscribed', function(e) { 
		alert('Subscribed to channel: '+e.channel);
	});


#### onUnsubscribed
Event fired when module unsubscribes from a channel.
The event parameter passed on the callback function has defined following property:
- **channel** [string]: the channel name

Example:

	ORTC.addEventListener('onUnsubscribed', function(e) { 
		alert('Unsubscribed from: '+e.channel);
	});


#### onMessage
Event fired when module receives a message on the subscribed channel.
The event parameter passed on the callback function has defined following properties:
- **channel** [string]: the channel name
- **message** [string]: the message

Example:

	ORTC.addEventListener('onMessage', function(e) {
		alert('(Channel: '+e.channel+') Message received: '+e.message);
	});

#### onPresence
Event fired as a response for presence request.
The event parameter passed on the callback function has defined following properties:
- **channel** [string]: the channel name
- **result** [string]: JSON string containing the presence response
- **error** [string]: the error description, if occurs, otherwise empty string

Example:

	ORTC.addEventListener('onPresence', function(e) {
		if (e.error != ""){
			alert('(Channel: '+e.channel+') Presence error: ' + e.error);
		} else {
			alert('(Channel: '+e.channel+') Presence: '+e.result);
		}
	});

### Methods

#### connect
Connects the client using the supplied application key and authentication token.
Parameters:
- **application_key** [string]: Your ORTC application key.
- **authentication_token** [string]: - Your ORTC authentication token (this parameter is optional).

Example:

	ORTC.connect('yourApplicationKey');
	or
	ORTC.connect('yourApplicationKey', 'yourAuthenticationToken');

#### disconnect
Disconnects the client.

Example:

	ORTC.disconnect();

#### subscribe
Subscribes to the supplied channel to receive messages sent to it.
Parameters:
- **channel** [string]: The channel name.
- **subscribe_on_reconnect** [bool] -Indicates whether the client should subscribe to the channel when reconnected (if it was previously subscribed when connected).

Example:

	ORTC.subscribe('yellow', true);
	
	
#### subscribeWithNotifications
Subscribes to the supplied channel to receive messages sent to it (with support of APNS).
Parameters:
- **channel** [string]: The channel name.
- **subscribe_on_reconnect** [bool] -Indicates whether the client should subscribe to the channel when reconnected (if it was previously subscribed when connected).

Note: For APNS support, please use the wrapper module co.realtime.ortc.apns.js

Example:

	ORTC.subscribeWithNotifications('yellow', true);	
	
#### unsubscribe
Unsubscribes from the supplied channel to stop receiving messages sent to it.
Parameter:
- **channel** [string]: The channel name.

Example:
	
	ORTC.unsubscribe('yellow');
	
#### send
Sends the supplied message to the supplied channel.
Parameters:
- **channel** [string]: The channel name.
- **message** [string]: The message to send.

Example:

	ORTC.send('yellow', 'This is the message');

#### isSubscribed
Returns boolean value which indicates whether the client is subscribed to the supplied channel.
Parameter:
- **channel** [string]: The channel name.

Example:

	alert(ORTC.isSubscribed('yellow'));

#### isConnected
Returns boolean value which indicates whether the client is connected. 

Example:

	alert(ORTC.isConnected());
	
#### presence
Gets a dictionary indicating the subscriptions number in the specified channel and if active the first 100 unique metadata.
Parameter: 
- **channel** [string]: The channel name with presence data active.

Example:
	
	ORTC.presence('yellow');
	
	
## Usage

Please see the examples files included in the directory 'example'

## Author

<ortc@realtime.co>
