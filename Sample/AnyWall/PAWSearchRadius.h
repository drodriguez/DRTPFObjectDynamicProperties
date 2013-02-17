//
//  PAWSearchRadius.h
//  AnyWall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PAWSearchRadius : NSObject <MKOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, assign) MKMapRect boundingMapRect;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius;

@end
