//
//  ViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 5/30/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "ViewController.h"
#import <Cordova/CDVViewController.h>
#import <Parse/Parse.h>
#import "NSObject+SEWebviewJSListener.h"
#import "DMWebBrowserViewController.h"
#import "Mixpanel.h"
#import "NearByStoresViewController.h"
#import "POIList.h"
#import "URLConnection.h"
@interface ViewController ()

@end

@implementation ViewController{
    CLLocation *location;
    int webViewLoads;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loading startAnimating];
    webViewLoads = 0;

    self.webView.delegate = (id)self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:refreshControl]; //<- this is point to use. Add "scrollView" property.


}

-(void)handleRefresh:(UIRefreshControl *)refresh {
    // Reload my data
    NSString* url=  self.webView.request.URL.absoluteString;
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSMutableArray * pairs = (NSMutableArray*)[components.query componentsSeparatedByString:@"&"];
    
    if([[pairs objectAtIndex:0] isEqualToString:@"latlng=null"]&&self.locationManager.location.coordinate.latitude>0){
        [pairs replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"latlng=%f,%f",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude ]];
        components.query = [NSString stringWithFormat:@"%@&%@",[pairs objectAtIndex:0],[pairs objectAtIndex:1]];
    

        NSLog(@"reloading url: %@",components.URL.absoluteString);
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:components.URL]];
    //[self.webView reload];
    [refresh endRefreshing];
    [PFAnalytics trackEvent:@"refresh"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    webViewLoads++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    webViewLoads--;
    [self.loading stopAnimating];
    if (webViewLoads > 0) {
        return;
    }
    
    
    NSString *currentURL = webView.request.URL.relativePath;
    NSLog(@"currentURL: %@",currentURL);
    if([currentURL isEqualToString:@"/mymovemobile/brands2"])
    {
        NSLog(@"loaded: %@",[[PFUser currentUser] username]);
        [[Mixpanel sharedInstance] identify:[[PFUser currentUser] objectId]];
        NSString* objectidStript = [NSString stringWithFormat:@"userObjID = '%@'",[[PFUser currentUser] objectId]];
        NSString* usernameStript = [NSString stringWithFormat:@"userName = '%@'",[[PFUser currentUser] username]];
        [webView stringByEvaluatingJavaScriptFromString:objectidStript];
        [webView stringByEvaluatingJavaScriptFromString:usernameStript];
        [webView stringByEvaluatingJavaScriptFromString:@"loginUser();checkCoupons();"];
    }
    //[webView stringByEvaluatingJavaScriptFromString:@"alert(JSON.stringify(currentUser));"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (webViewLoads > 0) {
        return NO;
    }
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSArray *requestArray = [requestString componentsSeparatedByString:@":##sendToApp##"];
    
    if ([requestArray count] > 1){
        NSString *requestPrefix = [[requestArray objectAtIndex:0] lowercaseString];
        NSString *requestMssg = ([requestArray count] > 0) ? [requestArray objectAtIndex:1] : @"";
        [self webviewMessageKey:requestPrefix value:requestMssg];
        return NO;
    }
    else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self shouldOpenLinksExternally]) {
        // open links in safari
        //[[UIApplication sharedApplication] openURL:[request URL]];
        return YES;
    }
    return YES;
}

-(void)webviewMessageKey:(NSString *)key value:(NSString *)val{

    if ([key isEqualToString:@"openwebview"]) {
        DMWebBrowserViewController *webBrowser = [[DMWebBrowserViewController alloc]
                                                  initWithURL:[NSURL URLWithString:val]
                                                  startLoadingWithBlock:^{
                                                      NSLog(@"start loading web browser page");
                                                  } andEndLoadingWithBlock:^{
                                                      NSLog(@"end loading web browser page");
                                                  }];
        //[webBrowser setNavBarColor:[UIColor orangeColor]];
        [self presentViewController:webBrowser animated:YES completion:nil];

    }
    
    if ([key isEqualToString:@"locationpermission"]) {
        [self initializeLocationManager];
        [self initializeLocationUpdates];
        
    }
    if ([key isEqualToString:@"opennearbymap"]) {
          [self performSegueWithIdentifier:@"nearbyStores" sender:val];
    }
    if ([key isEqualToString:@"turnonlocationreminder"]) {
        NSLog(@"turn on");
        NSArray* tempArry = [[NSArray alloc] initWithObjects:val, nil];
        URLConnection* uc = [[URLConnection alloc] init:tempArry :@"41.240252" :@"-73.034154"];
        uc.delegate = self;
        [uc returnListOfPoiObjects];
    }
    if ([key isEqualToString:@"turnofflocationreminder"]) {
         NSLog(@"turn off");
    }
}

- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    NSLog(@"location enable: %d",[CLLocationManager locationServicesEnabled]);
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"Location Services Error" : @"You need to enable location services to do location search."];
        return;
    }
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
        [self showAlertWithMessage:@"Location Permission Denied" : @"To enable, please go to Settings and turn on Location Service for MyMove."];
        return;
    }

    
    self.locationManager = [[CLLocationManager alloc] init];
}

- (void)initializeLocationUpdates {
    self.locationManager.desiredAccuracy = 50;
    //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -10.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    NSLog(@"new accuracy %f",newLocation.horizontalAccuracy);
    NSLog(@"accuracy %f",self.locationManager.desiredAccuracy);
    if (location == nil || oldLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
        
        //lastLocationError = nil;
        location = newLocation;
        
        
        if (newLocation.horizontalAccuracy <= 100) {
            
            [self.locationManager stopUpdatingLocation];
            NSString *currentLocationString = [NSString stringWithFormat:@"setCurrentLocation(%f,%f)",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude];
            [self.webView stringByEvaluatingJavaScriptFromString:currentLocationString];

            //log last seen location
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
            [PFUser currentUser][@"lastLocation"]=point;
            [[PFUser currentUser] saveInBackground];
            
            CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
            
            [reverseGeocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 
                 CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
                 NSString *city = myPlacemark.addressDictionary[@"City"];
                 NSString *state = myPlacemark.addressDictionary[@"State"];
                 //NSLog(@"My country code: %@ and countryName: %@", city, state);
                 NSString *locationTitle = [NSString stringWithFormat:@"setCurrentLocationTitle('%@, %@')",city, state];
                [self.webView stringByEvaluatingJavaScriptFromString:locationTitle];
             }];
        }
    }
    
}


- (void)showAlertWithMessage:(NSString*)title :(NSString*)alertText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController* nav = (UINavigationController*)segue.destinationViewController;
    NearByStoresViewController *nearby = (NearByStoresViewController *)[nav visibleViewController];
    //nearby.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    nearby.brandName = sender;
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)poiListDidFinishLoading:(POIList *)poiList{
    CLLocation *cl =  [[CLLocation alloc]initWithLatitude:41.240252 longitude:-73.03415 ];
    [poiList setupGeofence:[[UIDevice currentDevice] systemVersion] :cl ];
    
}

-(void)fenceTriggered:(POI *)poi{
 
}

@end
