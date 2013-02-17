//
//  PAWAppDelegate.h
//  AnyWall
//
//  Created by Christopher Bowns on 1/30/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

static NSUInteger const kPAWWallPostMaximumCharacterCount = 140;

static double const kPAWFeetToMeters = 0.3048; // this is an exact value.
static double const kPAWFeetToMiles = 5280.0; // this is an exact value.
static double const kPAWWallPostMaximumSearchDistance = 100.0;
static double const kPAWMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kPAWWallPostsSearch = 20; // query limit for pins and tableviewcells

// Parse API key constants:
static NSString * const kPAWParsePostsClassKey = @"Posts";
static NSString * const kPAWParseUserKey = @"user";
static NSString * const kPAWParseUsernameKey = @"username";
static NSString * const kPAWParseTextKey = @"text";
static NSString * const kPAWParseLocationKey = @"location";

// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";

// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";

#define PAWLocationAccuracy double

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class PAWWelcomeViewController;

@interface PAWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void)presentWelcomeViewController;

@end
