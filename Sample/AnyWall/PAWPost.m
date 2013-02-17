//
//  PAWPost.m
//  AnyWall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWPost.h"
#import "PAWAppDelegate.h"
#import <DRTPFObject+DynamicProperties.h>


struct PAWPostAttributes PAWPostAttributes = {
	.title = @"title",
	.subtitle = @"subtitle",
	.geopoint = @"geopoint",
	.user = @"user",
	.coordinate = @"coordinate"
};

@interface PAWPost ()

@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWPost

@dynamic title;
@dynamic subtitle;
@dynamic geopoint;
@dynamic user;

@synthesize animatesDrop;
@synthesize pinColor;

- (id)init {
	return [self initWithAutoClassName];
}

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
}

- (void)setGeopoint:(PFGeoPoint *)geopoint {
	if (geopoint != [self objectForKey:@"geopoint"]) {
		[self willChangeValueForKey:@"coordinate"];
		[self setObject:geopoint forKey:@"geopoint"];
		[self didChangeValueForKey:@"coordinate"];
	}
}

- (BOOL)equalToPost:(PAWPost *)aPost {
	if (aPost == nil) {
		return NO;
	}

	return [aPost.objectId compare:self.objectId] == NSOrderedSame;
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
	if (outside) {
//		self.subtitle = nil;
//		self.title = kPAWWallCantViewPost;
		self.pinColor = MKPinAnnotationColorRed;
	} else {
//		self.title = [self.object objectForKey:kPAWParseTextKey];
//		self.subtitle = [[self.object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey];
		self.pinColor = MKPinAnnotationColorGreen;
	}
}

@end
