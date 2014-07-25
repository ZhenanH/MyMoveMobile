//
//  URLConnection.h
//  LocationReminderLibrary
//
//  Created by xxduan on 7/1/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//
#ifdef __OBJC__
    #import "POI.h"
    #import "POIList.h"
#endif

@protocol URLConnectionDelegate <NSObject>

-(void) poiListDidFinishLoading:(POIList *)poiList;
@end

@interface URLConnection : NSObject {
    NSMutableData *_data;
    float counter;
    float totalPoi;
    NSMutableArray *listOfPois;
    NSMutableArray *listOfPoiIds;
    // Delegate to respond back
    id <URLConnectionDelegate> delegate;
}
@property (nonatomic,strong) id delegate;
@property (copy) NSMutableArray *names;
@property NSString *currLatitude;
@property NSString *currLongitude;

// define delegate property

// define public functions
- (URLConnection *)init:(NSArray *)names :(NSString *)lat :(NSString *)lon;
- (URLConnection *)initAll:(NSArray *)names :(NSString *)lat :(NSString *)lon :(NSString *)cost :(NSString *)limit;
- (NSString *) setupURL:(NSString *) name :(NSString *)param;

- (void) downloadFromURL:(NSString *)urlInput;
- (NSString *) parseFromJSON: (NSData *)json;
- (void) returnListOfPoiObjects;
- (void) returnListOfPoiIds;
- (void) storeList;

@end
