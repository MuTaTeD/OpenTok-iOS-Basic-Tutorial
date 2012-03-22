The OpenTokBasic sample app
===========================

The OpenTokBasic sample app is a sample app that shows all features of the OpenTok iOS library. It goes into more detail than the [OpenTokHello sample app](https://github.com/opentok/OpenTok-iOS-Hello-World).

The OpenTokBasic sample app lets you test the entire OpenTok iOS API. In addition to the features available in the OpenTokHello sample app,
the OpenTokBasic sample app lets you do the following:

- Determine the number of connections and streams in a session
- Decide whether to publish audio, video, or both when publishing a stream to a session
- Subscribe to audio, video, or both for streams in the session
- Get information about streams and connections
- Unsubscribe from streams
- Disconnect from a session

Before you test the sample app, be sure to read [Using the OpenTok iOS SDK](http://www.tokbox.com/opentok/ios/docs/docs/Using_iOS.html). Also, you may want to first look
at the [OpenTokHelloWorld](https://github.com/opentok/OpenTok-iOS-Hello-World) sample app.

Testing the sample app
----------------------

1. Open the OpentokIOSBasicApp.xcodeproj file in XCode.

2. Connect your iOS device to a USB port on your Mac. Make sure that your device is connected to a wifi network.

3. Select the XCode Organizer (Window > Organizer), and make sure that your device is provisioned to work with the sample app. For more information,
see the section on "Setting up your development environment" at [this page](https://developer.apple.com/programs/ios/gettingstarted/) at
the Apple iOS Dev Center.

4. In the main XCode project window, click the Run button (or select Product > Run).

	The app should start on your connected device.

5. Tap the Connect button to connect to the session. Once connected, tap the Publish button.

	Note that the number of connections and streams in the session is displayed at the top of the screen. These statistics are dynamically updated.

6. In the iPad app, tap the Unsubscribe button corresponding to a subscribed stream.

7. Tap the Unpublish button.

8. Tap the Disconnect button.

9. Close the app. Now set up the app to subscribe to audio-video streams other than your own:

	- In XCode, near the top of the ViewController.m file, change the `subscribeToSelf` property to be set to `NO`:

			static bool subscribeToSelf = NO;
	- Run the app on your iOS device again.
	- In a browser on your Mac, load the browser_demo.html file, included with the sample app, to add more streams to the session. 
	In the web page, click the Connect and Publish buttons.
	*Note:* If the web page asks you to set the Flash Player Settings, or if you do not see a display of your camera in the page, see the
	instructions in ["Flash Player Settings for local testing"](http://www.tokbox.com/opentok/api/tools/js/tutorials/helloworld.html#localTest).

10. You can generate a unique session ID at this URL:

		http://staging.tokbox.com/hl/session/create

	Change the `kSessionId` constant in the ViewController.m file and the `sessionId` to the new session ID. 

Understanding the code
----------------------

The OpenTokBasic app builds on the OpenTokHello app, showing more features of the OpenTok iOS SDK.
Review the description of the [OpenTokHello sample app](https://github.com/opentok/OpenTok-iOS-Hello-World) for basic information on:

- Initializing an OTSession object and connecting to an OpenTok session
- Publishing a stream to a session
- Subscribing to streams
- Removing dropped streams
- Knowing when you have disconnected from a session

The ViewController.m file contains the main implementation code that includes use of the OpenTok iOS SDK.

### Tracking the number of connections and streams in a session

When you initialize an OTSession object and connect to the session, in the `doConnect` method, you register a key-value observer
for the `connectionCount` property of the OTSession object:

	- (void)doConnect 
	{
	    _session = [[OTSession alloc] initWithSessionId:kSessionId
	                                           delegate:self];
	    [_session addObserver:self
	               forKeyPath:@"connectionCount"
	                  options:NSKeyValueObservingOptionNew
	                  context:nil];
	    [_session connectWithApiKey:kApiKey token:kToken];
	}

The `connectionCount` property is set dynamically to the number of connections in the session. When it changes, the key-value
observer updates the `_statusLabel` UILabel text with the new number of connections:

	- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
	{
	    if ([keyPath isEqualToString:@"connectionCount"]) {
	        _statusLabel.text = [NSString stringWithFormat:@"Connections: %d Streams: %d", ((OTSession*)object).connectionCount, _session.streams.count];
	    }
	}

Note that the `statusLabel` text string also references the `streams.count` property of the OTSession object. This gives the number of streams in the session. The `streams` property of the OTSession object is an array of OTStream objects, representing streams in the session, and it is updated dynamically as streams are added and dropped. Also, as streams are added and dropped, the `[OTSessionDelegate didAddStream]` and
`[OTSessionDelegate didDropStream]` messages are sent, and these also update the `_statusLabel` text:

	- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
	{
	    [self setStatusLabel];
	    //...
	}
	
	- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
	{
	    [self setStatusLabel];
	}
	
	- (void)setStatusLabel
	{
	    if (_session && _session.connectionCount > 0) {
	        _statusLabel.text = [NSString stringWithFormat:@"Connections: %d Streams: %d", _session.connectionCount, _session.streams.count];
	    } else {
	        _statusLabel.text = @"Not connected.";
	    }
	}
	

### Specifying whether to publish audio, video, or both

The OTPublisher object includes `publishAudio` and `publishVideo` properties. Before sending the `[OTSession publish:]` message, set these 
properties to determine whether your app publishes audio, video, or both. The sample code sets these values to constants (YES):

	- (void)doPublish
	{
	    _publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
	    _publisher.publishAudio = YES;
	    _publisher.publishVideo = YES;
	    [_session publish:_publisher];
	    [self.view addSubview:_publisher.view];
	    [_publisher.view setFrame:CGRectMake(0, topOffset, widgetWidth, widgetHeight)];
	}

Change the values of these properties and run the test app. The app publishes audio-only, video-only, or audio-video streams accordingly.
Your own app can set the `publishAudio` and `publishVideo` properties based on other factors, such as user interface selections. 

The view of the OTPublisher object is added as a subview of the ViewController's view.

### Specifying whether to subscribe to audio, video, or both

The OTSubscriber object includes `subscribeToAudio` and `subscribeToVideo` properties. Before calling the `[OTSession subscribe:]` message,
set these properties to determine whether your app publishes audio, video, or both. The sample code set these values to constants (YES) (in the
`[OTSessionDelegate session: didReceiveStream:]` method):

	OTSubscriber* subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
	subscriber.subscribeToAudio = YES;
	subscriber.subscribeToVideo = YES;

Change the values of these properties and run the test app. The app subscribes to audio-only, video-only, both audio and video accordingly.
Note however, that some streams do not include audio or video to begin with (based on the publisher's settings).  

### Getting information about streams and connections

As streams are added to the session, the `[OTSessionDelegate session: didReceiveStream:]` method uses `NSLog()` to log information about
the streams:

	NSLog(@"session: didReceiveStream:");
	NSLog(@"- connection.connectionId: %@", stream.connection.connectionId);
	NSLog(@"- connection.creationTime: %@", stream.connection.creationTime);
	NSLog(@"- session.sessionId: %@", stream.session.sessionId);
	NSLog(@"- streamId: %@", stream.streamId);
	NSLog(@"- type %@", stream.type);
	NSLog(@"- creationTime %@", stream.creationTime);
	NSLog(@"- name %@", stream.name);
	NSLog(@"- hasAudio %@", (stream.hasAudio ? @"YES" : @"NO"));
	NSLog(@"- hasVideo %@", (stream.hasVideo ? @"YES" : @"NO"));

Similarly, when a session connects, the `[OTSessionDelegate sessionDidConnect:]` method uses `NSLog()` to log information about
the connection:

	NSLog(@"sessionDidConnect: %@", session.sessionId);
	NSLog(@"- connectionId: %@", session.connection.connectionId);
	NSLog(@"- creationTime: %@", session.connection.creationTime);

### Unsubscribing from streams

When a stream is added to the session, the `[OTSessionDelegate session: didReceiveStream:]` method creates a SubscriberContainer instance.
The SubscriberContainer class is a ViewController that adds the view of the OTSubscriber as a subview along with a button that lets the user
unsubscribe. (The SubscriberContainer class is custom to the OpenTokBasic application. It is not a class in the OpenTok iOS SDK.) 

When the user taps the Unsubscribe button, the `unsubscribeButtonClicked()` method (defined in the SubscriberContainer.m file)
sends the `[OTSubscriber close]` message:

	[_subscriber close];

This causes the app to stop subscribing to the stream. The view of the OTSubscriber is automatically removed from its superview.
Other code in the app removes the SubscriberContainer (and its view) and updates the layout of any remaining subscriber views.

### Disconnecting from a session

When you connect to the session, the `[OTSessionDelegate sessionDidConnect:]` method makes the Disconnect and Publish buttons visible:

	- (void)sessionDidConnect:(OTSession*)session
	{
	    _disconnectButton.hidden = NO;
	    _publishButton.hidden = NO;
	    //...
	}

When the user clicks the Disconnect button, the `doDisconnect` method is invoked, which in turn sends the `[OTSession disconnect]` message:

	- (void)doDisconnect 
	{
	    [_session disconnect];
	}
