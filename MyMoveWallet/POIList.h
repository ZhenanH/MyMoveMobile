//
//  POIList.h
//  LocationReminderLibrary
//
//  Created by xxduan on 7/9/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//

#ifdef __OBJC__
    #import "POI.h"
    #import <CoreLocation/CoreLocation.h>
    #import <CoreLocation/CLRegion.h>
#endif

@protocol POIListDelegate <NSObject>
    -(void) fenceTriggered:(POI*) poi;
@end

@interface POIList: NSObject <CLLocationManagerDelegate>{
    id <POIListDelegate> delegate;
}

@property float radius;
@property (copy, nonatomic) NSMutableArray *listOfPois;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong) id delegate;

- (POIList *) init :(NSMutableArray *) list;
+ (instancetype)sharedInstance;

- (void)initializeLocationManager;
- (void)stopLocationUpdates;
- (void)initializeLocationUpdates;

- (NSMutableArray *) getClosestPois: (float)numberOfPois :(CLLocation *)currLocation;
- (BOOL)setupGeofence:(NSString *)version :(CLLocation *)currLocation;
- (BOOL) removeGeofence: (NSMutableArray *)listToRemove :(NSString *)version;
- (NSMutableArray *) getAllIds;
@end
