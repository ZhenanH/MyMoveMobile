//
//  URLConnection.m
//  LocationReminderLibrary
//
//  Created by xxduan on 7/1/14.
//  Copyright (c) 2014 ___pbi.stic.LocationReminderLibrary___. All rights reserved.
//

#import "URLConnection.h"

@implementation URLConnection
@synthesize delegate;

static NSString *idURL = @"http://10.50.9.229/locationcontext/v2/poi/search/travelarea?mode=Drive&units=Minutes";
static NSString *dataURL =@"http://10.50.9.229/locationcontext/v2/poi/id/";
static NSString *_paramGetData = @"payload";
static NSString *_paramGetId = @"poiIdList";
static NSString *_cost;
static NSString *_limit;


// Initialization

- (URLConnection *)init:(NSArray *)names :(NSString *)lat :(NSString *)lon{
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _names = [[NSMutableArray alloc] initWithArray:names];
        _currLatitude = lat;
        _currLongitude = lon;
        _cost = @"30";
        _limit = @"100";
        totalPoi = 0;
    }
    return self;
}

- (URLConnection *)initAll:(NSArray *)names :(NSString *)lat :(NSString *)lon :(NSString *)cost :(NSString *)limit{
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _names = [[NSMutableArray alloc] initWithArray:names];
        _currLatitude = lat;
        _currLongitude = lon;
        if ([cost floatValue] > 45)
            cost = @"45";
        _cost = cost;
        _limit = limit;
        totalPoi = 0;

    }
    return self;
}

// Setup the url for each store; if multiple store in the list, must read all of the store one by one
- (NSString *)setupURL:(NSString *)name :(NSString *) param{
    NSArray *pathArray;
    if (param == _paramGetData){
        pathArray = [[NSArray alloc]initWithObjects: dataURL, name, nil];
    
    }
    else {
        pathArray = [[NSArray alloc]initWithObjects: idURL,
                                @"&lat=", _currLatitude,
                                @"&lon=", _currLongitude,
                                @"&name=", name,
                                @"&cost=", _cost,
                                @"&limit=", _limit,
                                nil
                          ];
    }
    return [pathArray componentsJoinedByString:@""];
}
- (void) downloadFromURL:(NSString *)urlInput{
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[urlInput stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ]]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self]; 
    if (!connection) {
        // Release the receivedData object.
        _data = nil;
        NSLog(@"Failed to connect!");
        // Inform the user that the connection failed.
    }
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    // Handle the error properly
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [self parseFromJSON: _data];
    // counter ++;
    if (counter == 0) {
        // poiListDidFinsish

        if([delegate respondsToSelector: @selector(poiListDidFinishLoading:)]){
            //send the delegate function with the amount entered by the user
            POIList *list = [[POIList sharedInstance] init:listOfPois];
            //save list
            [self storeList];
            [delegate poiListDidFinishLoading: list];
        }
    } else if (counter == totalPoi){
        // all of poi ids are saved, call to download from id
        for (NSString *poi in listOfPoiIds){
            [self downloadFromURL:[self setupURL:poi :_paramGetData]];
        }
    }
}

- (NSString *) parseFromJSON: (NSData *)fromURL{
    NSError *localError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:fromURL options:0 error:&localError];
    NSString *result;
    if (localError != nil) {
        return nil;
    }
    // get all of the ids
    if ([json objectForKey: _paramGetId]){
        totalPoi = [json[@"count"] floatValue] + totalPoi;
        for(NSString *id in json[_paramGetId]){
            [listOfPoiIds addObject:id];
            counter ++;
        }
        result = @"Success";
        // getting poi data including name, lat, lon, address, name, postcode
    } else if ([json objectForKey: _paramGetData]){
        CLLocation *currLocation = [[CLLocation alloc]initWithLatitude:[_currLatitude doubleValue] longitude:[_currLongitude doubleValue]];
        NSDictionary *payload = json[_paramGetData];
        POI *newpoi = [[POI alloc] initAll:payload[@"name"] :payload[@"id"] :[payload[@"mm_Latitude"] floatValue]
                                            :[payload[@"mm_Longitude"] floatValue] :payload[@"mm_Address"]
                                          :payload[@"locname"] :payload[@"postcode"]];
        newpoi.distance = [newpoi distanceFromLocation:currLocation];
        [listOfPois addObject:newpoi];
        counter --;
        result = @"Success";
        
        //   [result addObject:(payload[poiParam])];
        // just getting a specific param from poi
    } else {
        NSDictionary *payload = json[_paramGetData];
        result = payload[_paramGetData];
    }
    
    return result;
}
- (void) returnListOfPoiObjects{
    listOfPois = [[NSMutableArray alloc] init];
    [self returnListOfPoiIds];
}
- (void) returnListOfPoiIds{
   listOfPoiIds = [[NSMutableArray alloc] init];
    for (NSString *name in _names) {
        NSString *url = [self setupURL :name :_paramGetId];
        [self downloadFromURL:url];
    }
}

- (void) storeList{
    for (POI *poi in listOfPois){
        NSString *identifier = [[NSArray arrayWithObjects:[poi name],[poi id], nil] componentsJoinedByString:@";"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        [prefs setObject:[poi toDictionary] forKey:identifier];  //set the prev Array for key value "favourites"
    }
}

@end
