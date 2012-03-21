//
//  ViewController.m
//  OpenTokBasic
//
//  Created by Jeff Swartz on 2/3/12.
//  Copyright (c) 2012 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    UIButton* _connectButton;
    UIButton* _disconnectButton;
    UIButton* _publishButton;
    UIButton* _unpublishButton;
    UIButton* _unsubscribeButton;
    UILabel* _statusLabel;
}
static int topOffset = 68;
static double widgetHeight = 240;
static double widgetWidth = 320;
static NSString* const kApiKey = @"1127";
static NSString* const kToken = @"devtoken";
static NSString* const kSessionId = @"2_MX4wfn4yMDEyLTAyLTA0IDAyOjIxOjI0LjE0ODMwNCswMDowMH4wLjQ2MDExMzM1NDczOH4";
static bool subscribeToSelf = YES; // Change to NO if you want to subscribe streams other than your own

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI
{
    _connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _connectButton.frame = CGRectMake(10, 10, 100, 44);
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton addTarget:self
                       action:@selector(connectButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectButton];    
    
    _disconnectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _disconnectButton.frame = CGRectMake(10, 10, 100, 44);
    [_disconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [_disconnectButton addTarget:self
                          action:@selector(disconnectButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    _disconnectButton.hidden = YES;
    [self.view addSubview:_disconnectButton];    
    
    _publishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _publishButton.frame = CGRectMake(120, 10, 100, 44);
    [_publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    [_publishButton addTarget:self
                          action:@selector(publishButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    _publishButton.hidden = YES;
    [self.view addSubview:_publishButton];    
    
    _unpublishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _unpublishButton.frame = CGRectMake(120, 10, 100, 44);
    [_unpublishButton setTitle:@"Unpublish" forState:UIControlStateNormal];
    [_unpublishButton addTarget:self
                         action:@selector(unpublishButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    _unpublishButton.hidden = YES;
    [self.view addSubview:_unpublishButton];
    
    _unsubscribeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _unsubscribeButton.frame = CGRectMake(10, 10 + topOffset + widgetHeight * 2, 100, 44);
    [_unsubscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
    [_unsubscribeButton addTarget:self
                         action:@selector(unsubscribeButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    _unsubscribeButton.hidden = YES;
    [self.view addSubview:_unsubscribeButton];
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(230, 10, 240, 44);
    [self setStatusLabel];
    [self.view addSubview:_statusLabel];
}

- (void)connectButtonClicked:(UIButton*)button
{
    _connectButton.hidden = YES;
    _statusLabel.text = @"Connecting...";
    [self doConnect];
}

- (void)disconnectButtonClicked:(UIButton*)button
{
    _disconnectButton.hidden = YES;
    [self doDisconnect];
}

- (void)publishButtonClicked:(UIButton*)button
{
    _publishButton.hidden = YES;
    [self doPublish];
}

- (void)unpublishButtonClicked:(UIButton*)button
{
    _unpublishButton.hidden = YES;
    [self doUnpublish];
}


- (void)unsubscribeButtonClicked:(UIButton*)button
{
    _unsubscribeButton.hidden = YES;
    [_subscriber close];
    _subscriber = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)updateSubscriber
{
    for (NSString* streamId in _session.streams) {
        OTStream* stream = [_session.streams valueForKey:streamId];
        if (stream.connection.connectionId != _session.connection.connectionId) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

#pragma mark - OpenTok methods

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

- (void)doDisconnect 
{
    [_session disconnect];
}

- (void)doPublish
{
    _publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
    _publisher.publishAudio = YES;
    _publisher.publishVideo = YES;
    [_session publish:_publisher];
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(0, topOffset, widgetWidth, widgetHeight)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"connectionCount"]) {
        [self setStatusLabel];
    }
}

- (void)doUnpublish
{
    [_session unpublish:_publisher];    
}

- (void)setStatusLabel
{
    if (_session && _session.connectionCount > 0) {
        _statusLabel.text = [NSString stringWithFormat:@"Connections: %d Streams: %d", _session.connectionCount, _session.streams.count];
    } else {
        _statusLabel.text = @"Not connected.";
    }
}

#pragma mark - OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session
{
    _disconnectButton.hidden = NO;
    _publishButton.hidden = NO;
    [self setStatusLabel];
    NSLog(@"sessionDidConnect: %@", session.sessionId);
    NSLog(@"- connectionId: %@", session.connection.connectionId);
    NSLog(@"- creationTime: %@", session.connection.creationTime);
}

- (void)sessionDidDisconnect:(OTSession*)session 
{
    _statusLabel.text = @"Disconnected from session.";
    _publishButton.hidden = YES;
    _unpublishButton.hidden = YES;
    NSLog(@"sessionDidDisconnect: %@", session.sessionId);    
    _connectButton.hidden = NO;
}

- (void)session:(OTSession*)session didFailWithError:(NSError*)error
{
    _connectButton.hidden = NO;
    NSLog(@"session:didFailWithError: %@", error.description);    
}

- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    [self setStatusLabel];
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
    if ( (subscribeToSelf && [stream.connection.connectionId isEqualToString: _session.connection.connectionId])
         ||
         (!subscribeToSelf && ![stream.connection.connectionId isEqualToString: _session.connection.connectionId])
       ) {
        if (!_subscriber) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            _subscriber.subscribeToAudio = YES;
            _subscriber.subscribeToVideo = YES;
        }
        NSLog(@"subscriber.session.sessionId: %@", _subscriber.session.sessionId);
        NSLog(@"- stream.streamId: %@", _subscriber.stream.streamId);
        NSLog(@"- subscribeToAudio %@", (_subscriber.subscribeToAudio ? @"YES" : @"NO"));
        NSLog(@"- subscribeToVideo %@", (_subscriber.subscribeToVideo ? @"YES" : @"NO"));
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    [self setStatusLabel];
    NSLog(@"session didDropStream (%@)", stream.streamId);
    if (!subscribeToSelf
        && _subscriber
        && [_subscriber.stream.streamId isEqualToString: stream.streamId]) {
            _subscriber = nil;
            _unsubscribeButton.hidden = YES;
            [self updateSubscriber];
    }
}

#pragma mark - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(NSError*) error {
    NSLog(@"publisher: %@ didFailWithError: %@", publisher, error.description);
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    _unpublishButton.hidden = NO;
    NSLog(@"publisherDidStartStreaming: %@", publisher);
    NSLog(@"- publisher.session: %@", publisher.session.sessionId);
    NSLog(@"- publisher.name: %@", publisher.name);
}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    _publishButton.hidden = NO;
    NSLog(@"publisherDidStopStreaming:%@", publisher);
}

#pragma mark - OTSubscriberDelegate methods

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [subscriber.view setFrame:CGRectMake(0, topOffset + widgetHeight, widgetWidth, widgetHeight)];
    [self.view addSubview:subscriber.view];
}

- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber {
    NSLog(@"subscriberVideoDataReceived (%@)", subscriber.stream.streamId);
    _unsubscribeButton.hidden = NO;
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(NSError *)error
{
    NSLog(@"subscriber: %@ didFailWithError: %@", subscriber.stream.streamId, error.description);
}

@end
