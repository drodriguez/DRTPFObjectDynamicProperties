//
//  PAWAppDelegate.m
//  AnyWall
//
//  Created by Christopher Bowns on 1/30/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import "PAWAppDelegate.h"
#import "ParseCredentials.h"

#import <Parse/Parse.h>

#import "PAWWelcomeViewController.h"
#import "PAWWallViewController.h"

@interface PAWAppDelegate ()

void uncaughtExceptionHandler(NSException *exception);

@end

@implementation PAWAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize filterDistance;
@synthesize currentLocation;

- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance
{
	filterDistance = aFilterDistance;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:filterDistance forKey:defaultsFilterDistanceKey];
	[userDefaults synchronize];

	// Notify the app of the filterDistance change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:filterDistance] forKey:kPAWFilterDistanceKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWFilterDistanceChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)setCurrentLocation:(CLLocation *)aCurrentLocation
{
	currentLocation = aCurrentLocation;

	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:kPAWLocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWLocationChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)presentWelcomeViewController;
{
	// Go to the welcome screen and have them log in or create an account.
	PAWWelcomeViewController *welcomeViewController = [[PAWWelcomeViewController alloc] initWithNibName:@"PAWWelcomeViewController" bundle:nil];
	welcomeViewController.title = @"Welcome to AnyWall";
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;

	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}

#pragma mark - Application delegation methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	
	// ****************************************************************************
	// Fill in with your Parse credentials:
	// ****************************************************************************

	[Parse setApplicationId:ParseCredentialApplicationID clientKey:ParseCredentialClientKey];

	// Grab values from NSUserDefaults:
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	// Set the global tint on the navigation bar
	[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];

	// Desired search radius:
	if ([userDefaults doubleForKey:defaultsFilterDistanceKey]) {
		// use the ivar instead of self.accuracy to avoid an unnecessary write to NAND on launch.
		filterDistance = [userDefaults doubleForKey:defaultsFilterDistanceKey];
	} else {
		// if we have no accuracy in defaults, set it to 1000 feet.
		self.filterDistance = 1000 * kPAWFeetToMeters;
	}
	

	UINavigationController *navController = nil;

	PFUser *currentUser = [PFUser currentUser];
	if (currentUser) {
		// Skip straight to the main view.
		PAWWallViewController *wallViewController = [[PAWWallViewController alloc] initWithNibName:nil bundle:nil];
		navController = [[UINavigationController alloc] initWithRootViewController:wallViewController];
		navController.navigationBarHidden = NO;
		self.viewController = navController;
		self.window.rootViewController = self.viewController;
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

// Via http://stackoverflow.com/questions/7841610/xcode-4-2-debug-doesnt-symbolicate-stack-call

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@end
