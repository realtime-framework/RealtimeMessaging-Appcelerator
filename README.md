## Realtime Messaging modules for Appcelarator

These modules allows the integration of Realtime Messaging services (aka ORTC) in Appcelerator applications.

Part of the [The Realtime® Framework](http://framework.realtime.co), Realtime Cloud Messaging (aka ORTC) is a secure, fast and highly scalable cloud-hosted Pub/Sub real-time message broker for web and mobile apps.

If your app has data that needs to be updated in the user’s interface as it changes (e.g. real-time stock quotes or ever changing social news feed) Realtime Cloud Messaging is the reliable, easy, unbelievably fast, “works everywhere” solution.

Requirements: Android => 2.3.3

## Installation

For information how to use Titanium Modules, please follow the guide [here](http://wiki.appcelerator.org/display/tis/Using+Titanium+Modules).

Require module **Ti.map**

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
	
#### onNotification
Event fired when module receives a push notification. The event parameter passed on the callback function has defined following properties:

- **channel** [string]: the channel name
- **message** [string]: the message
- **payload** [string]: the payload

Example:

	ORTC.addEventListener('onNotification', function(e) {
    alert('(Channel: '+e.channel+') Message received: '+e.message + ' payload: ' + e.payload);
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
Subscribes with notification to the supplied channel to receive messages sent to it.
Parameters:
- **channel** [string]: The channel name.
- **subscribe_on_reconnect** [bool] -Indicates whether the client should subscribe to the channel when reconnected (if it was previously subscribed when connected).

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
	
#### setGoogleProjectId
Sets the Google Project ID. Not necessary if you are not going to use ORTC with Google Cloud Messaging.
Parameters:
- **googleProjectId** [string]: Project Id of your Google project.

Example:

	ortc.setGoogleProjectId('PROJECT_ID');

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
	
## Push notifications guide

For using ORTC Titanium SDK with push notifications from GCM.

- Create a google project, more info [here](http://messaging-public.realtime.co/documentation/starting-guide/mobilePushGCM.html).

- Set notification title to be displayed in the notification manager.

		ortc.setNotificationTitle('[App name for example]');


- Before connect set your Google project id: 

		ortc.setGoogleProjectId('462540995476');
		ortc.clusterUrl = 'http://ortc-developers.realtime.co/server/2.1';
		if(taAuthToken.value != '') {
			ortc.connect(taAppKey.value, taAuthToken.value);
		} else {
			ortc.connect(taAppKey.value);
		}
		
- Set onNotification eventListener. 

		ortc.addEventListener('onNotification', function(e) {
			addRowToEvents('(onNotification Channel: '+e.channel+') Message received: '+e.message+' Payload received: '+e.payload);
			Titanium.API.log('(onNotification Channel: '+e.channel+') Message received: '+e.message);
		});
		
- Use subscribeWithNotifications to subscribe the channel.
		
		ortc.subscribeWithNotifications(taChannel.value, true);
		
- Add the folling entrys to your application TiApp.xml, replace **[Titanium project identifier]** :

		    <android xmlns:android="http://schemas.android.com/apk/res/android">
		        <manifest>
		            <permission
		                android:name="[Titanium project identifier].permission.C2D_MESSAGE" android:protectionLevel="signature"/>
		            <uses-permission android:name="[Titanium project identifier].permission.C2D_MESSAGE"/>
		            <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
		            <uses-permission
		                android:name="android.permission.GET_TASKS"/> //detect if app is running from service
		            <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE"/>
		            <uses-permission android:name="android.permission.WAKE_LOCK"/>
		            <application android:debuggable="true">
		                <service android:name="co.realtime.ortc.BackgroundService"/>
		                <service android:name="ibt.ortc.extensibility.GcmOrtcIntentService"/>
		                <receiver
		                    android:name="ibt.ortc.extensibility.GcmOrtcBroadcastReceiver" android:permission="com.google.android.c2dm.permission.SEND">
		                    <intent-filter>
		                        <action android:name="com.google.android.c2dm.intent.RECEIVE"/>
		                        <action android:name="android.intent.action.BOOT_COMPLETED"/>
		                        <category android:name="[Titanium project identifier]"/>
		                    </intent-filter>
		                    <intent-filter>
		                        <action android:name="com.google.android.c2dm.intent.REGISTRATION"/>
		                        <category android:name="[Titanium project identifier]"/>
		                        <action android:name="android.intent.action.BOOT_COMPLETED"/>
		                    </intent-filter>
		                </receiver>
		            </application>
		        </manifest>
		    </android>

		

		



	
## Usage

Please see the examples files included in the directory 'example'

## Author
Realtime.co
