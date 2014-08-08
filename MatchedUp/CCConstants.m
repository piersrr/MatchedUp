//
//  CCConstants.m
//  MatchedUp
//
//  Created by Piers Rudgard-Redsell on 28/05/2014.
//  Copyright (c) 2014 Airbyte. All rights reserved.
//

#import "CCConstants.h"

@implementation CCConstants

#pragma mark - user Class

NSString *const kCCUserTagLineKey = @"tagLine";

NSString *const kCCUserProfileKey = @"profile";

NSString *const kCCUserProfileNameKey = @"name";
NSString *const kCCUserProfileFirstNameKey = @"firstName";
NSString *const kCCUserProfileLocationKey = @"location";
NSString *const kCCUserProfileGenderKey = @"gender";
NSString *const kCCUserProfileBirthdayKey = @"birthday";
NSString *const kCCUserProfileInterestedInKey = @"interestedIn";
NSString *const kCCUserProfilePictureURL                = @"pictureURL";
NSString *const kCCUserProfileRelationshipStatusKey     = @"relationshipStatus";
NSString *const kCCUserProfileAgeKey                    = @"age";

#pragma mark - photo class

 NSString *const kCCPhotoClassKey = @"Photo";
 NSString *const kCCPhotoUserKey = @"user";
 NSString *const kCCPhotoPictureKey = @"image";


#pragma mark - activity class

 NSString *const kCCActivityClassKey = @"Activity"; //capital because it's a class
 NSString *const kCCActivityTypeKey = @"type";
 NSString *const kCCActivityFromUserKey = @"fromUser";
 NSString *const kCCActivityToUserKey = @"toUser";
 NSString *const kCCActivityPhotoKey = @"photo";
 NSString *const kCCActivityTypeLikeKey = @"like";
 NSString *const kCCActivityTypeDislikeKey = @"dislike";

#pragma mark - settings


NSString *const kCCMenEnabledKey = @"men";
NSString *const kCCWomenEnabledKey = @"women";
NSString *const kCCSingleEnabledKey = @"single";
NSString *const kCCAgeMaxKey = @"ageMax";

@end
