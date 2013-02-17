//
//  PAWSearchRadius.m
//  AnyWall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWSearchRadius.h"

@implementation PAWSearchRadius

//@protocol MKOverlay <MKAnnotation>
//@required

// From MKAnnotation, for areas this should return the centroid of the area.
// @property (nonatomic, assign) CLLocationCoordinate2D coordinate;
// Done below:

@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize radius;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.radius = aRadius;
	}
	return self;
}

// boundingMapRect should be the smallest rectangle that completely contains the overlay.
// For overlays that span the 180th meridian, boundingMapRect should have either a negative MinX or a MaxX that is greater than MKMapSizeWorld.width.
// @property (nonatomic, readonly) MKMapRect boundingMapRect;

- (MKMapRect)boundingMapRect {
	return MKMapRectWorld; // this has severe performance implications.
}

//@optional
// Implement intersectsMapRect to provide more precise control over when the view for the overlay should be shown.
// If omitted, MKMapRectIntersectsRect([overlay boundingRect], mapRect) will be used instead.
// - (BOOL)intersectsMapRect:(MKMapRect)mapRect;

@end
