//
//  CCLoginViewController.m
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 25/05/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "CCLoginViewController.h"

@interface CCLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;
@end

@implementation CCLoginViewController

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
    
    self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
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

#pragma mark - IBActions


- (IBAction)loginButtonPressed:(UIButton *)sender {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me",@"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"]; //lecture 296. these are defined in facebook dev docs. these are what we will request from facebook.
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login error" message:@"Facebook login cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }
        
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
    
}

#pragma mark - helper method

-(void)updateUserInformation {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) { //block. lecture 298
        
        //NSLog(@"%@",result);
        
        if (!error) {
            //convert to dictionary so we can use quick access through key casting
            NSDictionary *userDictionary = (NSDictionary *)result; //we are telling program that result is a dictionary. (because we just know it is)
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]]; //lecture 302
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8]; //initwithcapacity helps program in efficicney, by allowing it to estimate memory allocation
            if (userDictionary[@"name"]) {
                userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) { //embedded dictionary. I think this structure must be documented in Facebook Dev stuff (or Parse docs)
                userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kCCUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            if (userDictionary[@"relationship_status"]) {
                userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString]; //lecture 302
            }
            
            
            [[PFUser currentUser] setObject:userProfile forKey:kCCUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        }
        else {
            NSLog(@"Error in FB request: %@", error);
        }
    }];
}

- (void)uploadPFFileToParse:(UIImage *)image //lecture 303
{
    NSLog(@"upload called");
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData){
        NSLog(@"imageData was not found.");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kCCPhotoUserKey];
            [photo setObject:photoFile forKey:kCCPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully");
            }];
        }
    }];
}

-(void)requestImage { //lecture 304
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0)
        {
            PFUser *user = [PFUser currentUser];
            
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"connection did recieve data");
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
     NSLog(@"connectionDidFinishLoading");
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

@end
