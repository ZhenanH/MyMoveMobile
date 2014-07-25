//
//  POI.h
//  LocationReminderLibrary
//
//  Created by xxduan on 7/8/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//
#ifdef __OBJC__
    #import <MapKit/MapKit.h>
#endif

@interface POI : NSObject {
      //SimpleGeofence mUIGeofence;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *id;
@property float latitude;
@property float longitude;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postCode;
@property float distance;
@property BOOL triggered;
- (POI *)initWithLocation:(NSString *)name :(NSString*)id :(float)lat :(float)lon;
- (POI *)initAll: (NSString *)name :(NSString *)id : (float)lat :(float)lon
    :(NSString *)address :(NSString *)city :(NSString *)postCode;

- (float) distanceFromLocation:(CLLocation *) endLocation;
- (float) distanceFromPoi: (POI *) endPOI;
- (float) distanceFromPoint: (float) lat :(float) lon;
- (NSDictionary *) toDictionary;
@end
