//
//  CCChatViewController.m
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 05/08/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "CCChatViewController.h"

@interface CCChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation CCChatViewController

-(NSMutableArray *)chats {
    if (!_chats) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    
    if  ([testUser1.objectId isEqual:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[@"user2"];
    }
    else {
        self.withUser = self.chatRoom[@"user1"];
    }
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//leccy 347
#pragma mark - TabelView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}

#pragma mark - TableView Delegate

-(void)didSendText:(NSString *)text { //348
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:@"Chat"]; //create chat object, with class chat
        [chat setObject:self.chatRoom forKey:@"chatroom"]; //knows which chat it is
        [chat setObject:self.currentUser forKey:@"fromUser"]; //who was it sent from / to
        [chat setObject:self.withUser forKey:@"toUser"];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId ]) {
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

//leccy 351 for more methods that are deprecated in the latest jsmessages...


-(JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

-(JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPTIONAL

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing){
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}
@end
