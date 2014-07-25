//
//  POIList.m
//  LocationReminderLibrary
//
//  Created by xxduan on 7/9/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#import "POIList.h"
@implementation POIList
@synthesize delegate;

- (POIList *) init:(NSMutableArray *)list{
    self = [super init];
    if (self) {
        _radius = 1000;
        _listOfPois = [[NSMutableArray alloc] initWithArray:list];
     }
    return self;
}

+ (instancetype)sharedInstance
{
    static POIList *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}
- (NSMutableArray *) getAllIds {
    NSMutableArray *listOfPoiIds = [[NSMutableArray alloc] init];
    for(POI *poi in _listOfPois) {
        [listOfPoiIds addObject: [poi id]];
    }
    return listOfPoiIds;
}
- (NSMutableArray *)getClosestPois:(float)numberOfPois :(CLLocation *)currLocation{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_distance"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;

    sortedArray = [_listOfPois sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithArray:
                              [sortedArray subarrayWithRange:
                               (NSMakeRange(0, numberOfPois))]];
    return result;
}

- (void)initializeLocationManager {
    if(![CLLocationManager locationServicesEnabled]) {
        [NSException raise:@"Location service not enabaled" format: @"You need to enable location services to use this app."];
        return;
    }
    // Initialize Location Manager
    _locationManager = [[CLLocationManager alloc] init];

    // Configure Location Manager
    [_locationManager setDelegate:self];

    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self initializeLocationUpdates];
}
- (void)stopLocationUpdates {
    [_locationManager stopUpdatingLocation];
}

- (void)initializeLocationUpdates {
    [_locationManager startUpdatingLocation];
}
- (BOOL)setupGeofence:(NSString *)version :(CLLocation *)currLocation{
    // Initiailize locaiton manager
    [self initializeLocationManager];
    if(![CLLocationManager locationServicesEnabled]) {
        [NSException raise:@"Location service not enabaled" format: @"You need to enable location services to use this app."];
        return false;
    }
    NSMutableArray *listToSetup = [[NSMutableArray alloc] init];

    if ([_listOfPois count] > 10){
        listToSetup = [self getClosestPois:10 :currLocation];
    }
    else {
        listToSetup = _listOfPois;
    }
    if(_radius > _locationManager.maximumRegionMonitoringDistance){
        _radius = _locationManager.maximumRegionMonitoringDistance;
    }
    
    for (POI *poi in listToSetup) {
        //NSLog(@"name: %@, lat: %f, lon:%f", poi.name, poi.latitude, poi.longitude);
        [_locationManager startMonitoringForRegion:[self poiToRegion:poi :version]];
    }
    return true;
}

- (CLRegion*)poiToRegion:(POI *)poi :(NSString *)version{
    NSString *identifier = [[NSArray arrayWithObjects:[poi name],[poi id],
                             nil] componentsJoinedByString:@";"];

    CLLocationDegrees latitude = [poi latitude];
    CLLocationDegrees longitude =[poi longitude];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    if([version floatValue] >= 7.0f) { // for ios 7
        return [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:_radius
                                                identifier:identifier];
    }
    else { // ios 7 below
        return [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                       radius:_radius
                                                   identifier:identifier];
    }
}
#pragma mark - Location Manager - Region Task Methods
// entry
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //read poi
    NSLog(@"Entered Region - %@", region.identifier);

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [prefs objectForKey:[region identifier]];
    if([delegate respondsToSelector: @selector(fenceTriggered:)]){
        [delegate fenceTriggered:[self dictToPOI:dictionary]];
    }
}

//currently in
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    //read poi
    NSLog(@"Currently in region: %@", region.identifier);
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dictionary = [prefs objectForKey:[region identifier]];
//    if([delegate respondsToSelector: @selector(fenceTriggered:)]){
//        [delegate fenceTriggered:[self dictToPOI:dictionary]];
//    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error : %@",error);
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    NSLog(@"Exited Region - %@", region.identifier);
}
//start monitor
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"failed monitoring %@ region, reason:%@ ", region.identifier, error);
}
- (BOOL) removeGeofence:(NSMutableArray *)listToRemove :(NSString *)version{
    
    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
        return false;
    }
    for (POI *poi in listToRemove) {
        [_locationManager stopMonitoringForRegion: [self poiToRegion:poi :version]];
    }
    return true;
}

-(POI *)dictToPOI: (NSDictionary *) dictionary{
    POI *newpoi = [[POI alloc] initAll:dictionary[@"name"] :dictionary[@"id"] :[dictionary[@"latitude"] floatValue]
                                      :[dictionary[@"longitude"] floatValue] :dictionary[@"address"]
                                      :dictionary[@"city"] :dictionary[@"postcode"]];
    return newpoi;
}
@end
