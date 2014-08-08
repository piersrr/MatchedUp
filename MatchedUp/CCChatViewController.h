//
//  CCChatViewController.h
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 05/08/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface CCChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
