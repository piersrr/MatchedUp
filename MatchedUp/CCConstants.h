//
//  CCConstants.h
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 28/05/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCConstants : NSObject

#pragma mark - User Class


extern NSString *const kCCUserTagLineKey;

//lecture 300
//global constants better than defines as you can set type

//keeps pointer open for entire life cycle of app
extern NSString *const kCCUserProfileKey;
extern NSString *const kCCUserProfileNameKey; //start with letter k for constant, class prefix and then what you want it to do, so userprofile
extern NSString *const kCCUserProfileFirstNameKey;
extern NSString *const kCCUserProfileLocationKey;
extern NSString *const kCCUserProfileGenderKey;
extern NSString *const kCCUserProfileBirthdayKey;
extern NSString *const kCCUserProfileInterestedInKey;
extern NSString *const kCCUserProfilePictureURL;
extern NSString *const kCCUserProfileRelationshipStatusKey;
extern NSString *const kCCUserProfileAgeKey;

#pragma mark - Photo class

extern NSString *const kCCPhotoClassKey;
extern NSString *const kCCPhotoUserKey;
extern NSString *const kCCPhotoPictureKey;


#pragma mark - Activity class

extern NSString *const kCCActivityClassKey;
extern NSString *const kCCActivityTypeKey;
extern NSString *const kCCActivityFromUserKey;
extern NSString *const kCCActivityToUserKey;
extern NSString *const kCCActivityPhotoKey;
extern NSString *const kCCActivityTypeLikeKey;
extern NSString *const kCCActivityTypeDislikeKey;

#pragma mark = settings

extern NSString *const kCCMenEnabledKey;
extern NSString *const kCCWomenEnabledKey;
extern NSString *const kCCSingleEnabledKey;
extern NSString *const kCCAgeMaxKey;

@end
