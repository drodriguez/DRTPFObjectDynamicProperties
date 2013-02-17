//
//  PAWPost.m
//  AnyWall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWPost.h"
#import "PAWAppDelegate.h"

@interface PAWPost ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWPost

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

@synthesize object;
@synthesize geopoint;
@synthesize user;
@synthesize animatesDrop;
@synthesize pinColor;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
		self.animatesDrop = NO;
	}
	return self;
}

- (id)initWithPFObject:(PFObject *)anObject {
	self.object = anObject;
	self.geopoint = [anObject objectForKey:kPAWParseLocationKey];
	self.user = [anObject objectForKey:kPAWParseUserKey];

	[anObject fetchIfNeeded]; 
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [anObject objectForKey:kPAWParseTextKey];
	NSString *aSubtitle = [[anObject objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey];

	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}

- (BOOL)equalToPost:(PAWPost *)aPost {
	if (aPost == nil) {
		return NO;
	}

	if (aPost.object && self.object) {
		// We have a PFObject inside the PAWPost, use that instead.
		if ([aPost.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:
		NSLog(@"%s Testing equality of PAWPosts where one or both objects lack a backing PFObject", __PRETTY_FUNCTION__);

		if ([aPost.title    compare:self.title]    != NSOrderedSame ||
			[aPost.subtitle compare:self.subtitle] != NSOrderedSame ||
			aPost.coordinate.latitude  != self.coordinate.latitude ||
			aPost.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}

		return YES;
	}
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
	if (outside) {
		self.subtitle = nil;
		self.title = kPAWWallCantViewPost;
		self.pinColor = MKPinAnnotationColorRed;
	} else {
		self.title = [self.object objectForKey:kPAWParseTextKey];
		self.subtitle = [[self.object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey];
		self.pinColor = MKPinAnnotationColorGreen;
	}
}

@end
