//
//  CCMatchViewController.h
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 03/08/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCMatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;


@end

@interface CCMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <CCMatchViewControllerDelegate> delegate;

@end
