//
//  PAWPost.h
//  AnyWall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

extern struct PAWPostAttributes {
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *subtitle;
	__unsafe_unretained NSString *geopoint;
	__unsafe_unretained NSString *user;
	__unsafe_unretained NSString *coordinate;
} PAWPostAttributes;

@interface PAWPost : PFObject <MKAnnotation>

//@protocol MKAnnotation <NSObject>

// Center latitude and longitude of the annotion view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// @optional
// Title and subtitle for use by selection UI.
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
// @end

// Other properties:
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

- (BOOL)equalToPost:(PAWPost *)aPost;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;

@end
