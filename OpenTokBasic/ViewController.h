//
//  ViewController.h
//  OpenTokBasic
//
//  Created by Jeff Swartz on 2/3/12.
//  Copyright (c) 2012 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenTok/Opentok.h>

@interface ViewController : UIViewController <OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate>
- (void)doConnect;
- (void)doDisconnect;
- (void)doPublish;
- (void)doUnpublish;
- (void)createUI;
- (void)setStatusLabel;
@end
