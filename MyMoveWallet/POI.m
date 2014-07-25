//
//  POI.m
//  LocationReminderLibrary
//
//  Created by xxduan on 7/8/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//

#import "POI.h"

@implementation POI

- (POI *)initWithLocation:(NSString *)name :(NSString*)id :(float)lat :(float)lon{
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _name = name;
        _id = id;
        _latitude = lat;
        _longitude = lon;
        _distance = -1;
        _triggered = false;
    }
    return self;
}

- (POI *)initAll: (NSString *)name :(NSString *)id : (float)lat :(float)lon
        :(NSString *)address :(NSString *)city :(NSString *)postCode {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _name = name;
        _id = id;
        _latitude = lat;
        _longitude = lon;
        _address = address;
        _city = city;
        _postCode = postCode;
        _distance = -1;
        _triggered = false;
    }
    return self;
}
- (float) distanceFromPoint: (float) endLat :(float) endLon {
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:endLat longitude:endLon];
    _distance =[self distanceFromLocation:endLocation];
    return _distance;
}
- (float) distanceFromPoi: (POI *) endPOI{
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[endPOI latitude] longitude:[endPOI longitude]];
    _distance = [self distanceFromLocation:endLocation];
    return _distance;
}

- (float) distanceFromLocation:(CLLocation *) endLocation{
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
    return [startLocation distanceFromLocation:endLocation];
}

- (NSDictionary *) toDictionary{
    NSDictionary *poiD = @{
                                @"name" : _name,
                                @"id": _id,
                                @"latitude": [[NSNumber alloc] initWithFloat: _latitude],
                                @"longitude": [[NSNumber alloc] initWithFloat: _longitude],
                                @"distance": [[NSNumber alloc] initWithFloat: _distance],
                                @"address": _address,
                                @"city": _city,
                                @"postCode": _postCode
                                };
    return poiD;
}
@end
