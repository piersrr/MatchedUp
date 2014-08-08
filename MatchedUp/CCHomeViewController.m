//
//  CCHomeViewController.m
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 23/07/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "CCHomeViewController.h"
#import "CCTestUser.h"
#import "CCProfileViewController.h"
#import "CCMatchViewController.h"

@interface CCHomeViewController () <CCMatchViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;

@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation CCHomeViewController

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
    
    //[CCTestUser saveTestUserToParse]; //lec 326
    
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey]; //lecture 314
    [query whereKey:kCCPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kCCPhotoUserKey]; //when we download photo (above), we should also download the user details that go with that photo
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //code that evaluates when block is done
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
        CCProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
    }
    
    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"]) {
        CCMatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image; //leccy 339
        matchVC.delegate = self;
    }
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


#pragma mark - IBActions
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDisLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}

#pragma mark - helper methods

-(void)queryForCurrentPhotoIndex { //lecture 315
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kCCPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else NSLog(@"%@", error);
        }];
        PFQuery *queryForLike = [PFQuery queryWithClassName:kCCActivityClassKey]; //leccy 323. two queries
        [queryForLike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
        [queryForLike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kCCActivityFromUserKey equalTo:[PFUser currentUser]]; //only get likes for current user/photo

        PFQuery *queryForDislike = [PFQuery queryWithClassName:kCCActivityClassKey]; //only get dislikes for current user/photo
        [queryForDislike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeDislikeKey];
        [queryForDislike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kCCActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) { //run query on background thread
            if (!error) {
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) { //we haven't liked user yet
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else { //we have liked, so some swapping might be needed
                    PFObject *activity = self.activities[0];
                    if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeDislikeKey]) {
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else {
                        //some other activity
                    }
                }
                self.likeButton.enabled = YES; //user can't do anything until we finish checking whether current photo is liked or disliked by current user
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
        
    }
}

-(void)updateView { //leccy 316
    self.firstNameLabel.text = self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kCCPhotoUserKey][kCCUserTagLineKey];
}

-(void)setupNextPhoto { //leccy 317
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users" message:@"Check back later for more people" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kCCActivityClassKey];
    [likeActivity setObject:kCCActivityTypeLikeKey forKey:kCCActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey]; //leccy 318. work out which photo is giver/receiver
    [likeActivity setObject:self.photo forKey:kCCActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

-(void)saveDislike {
    PFObject *dislikeActvity = [PFObject objectWithClassName:kCCActivityClassKey];
    [dislikeActvity setObject:kCCActivityTypeDislikeKey forKey:kCCActivityTypeKey];
    [dislikeActvity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    [dislikeActvity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey];
    [dislikeActvity setObject:self.photo forKey:kCCActivityPhotoKey];
    [dislikeActvity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActvity];
        [self setupNextPhoto];
    }];
}

-(void)checkLike { //leccy 320
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

-(void)checkDisLike {
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

-(void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kCCActivityClassKey];
    [query whereKey:kCCActivityFromUserKey equalTo:self.photo[kCCPhotoUserKey]]; //get activty equal to photo I'm viewing
    [query whereKey:kCCActivityToUserKey equalTo:[PFUser currentUser]];//additional constraint to only get if they liked me
    [query whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [self createChatroom];
        }
    }];
}

-(void)createChatroom {
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kCCPhotoUserKey]];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kCCPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatroom setObject:self.photo[kCCPhotoUserKey] forKey:@"user2"];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSeque" sender:nil];
            }];
        }
    }];
}


#pragma mark - CCMatchViewController Delegate

-(void)presentMatchesViewController { //341
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}

@end
