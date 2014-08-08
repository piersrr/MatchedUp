//
//  CCEditProfileViewController.m
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 24/07/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "CCEditProfileViewController.h"

@interface CCEditProfileViewController ()
@property (strong, nonatomic) IBOutlet UITextView *taglineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation CCEditProfileViewController

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
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey]; //leccy 331
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    
    self.taglineTextView.text = [[PFUser currentUser] objectForKey:kCCUserTagLineKey];
    
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

#pragma mark – ibactions

- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender {
    
    [[PFUser currentUser] setObject:self.taglineTextView.text forKey:kCCUserTagLineKey];
    [[PFUser currentUser] saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
