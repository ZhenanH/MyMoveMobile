//
//  LocalDealViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/7/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "LocalDealViewController.h"
#import <Parse/Parse.h>
#import "NSObject+SEWebviewJSListener.h"
#import "DMWebBrowserViewController.h"
#import "Mixpanel.h"
@interface LocalDealViewController ()

@end

@implementation LocalDealViewController
{
 CLLocation *location;
int webViewLoads;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.loading startAnimating];
    webViewLoads=0;
    self.webView.delegate = (id)self;
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    [self initializeLocationManager];
    [self initializeLocationUpdates];
    

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
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         
         CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
         NSString *city = myPlacemark.addressDictionary[@"City"];
         NSString *state = myPlacemark.addressDictionary[@"State"];
         //NSLog(@"My country code: %@ and countryName: %@", city, state);
         NSString *locationTitle = [NSString stringWithFormat:@"setCurrentLocationTitle('%@, %@')",city, state];
         [self.webView stringByEvaluatingJavaScriptFromString:locationTitle];
         NSLog(@"setting title");
     }];

    NSLog(@"done loading");
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
        
        
        if (newLocation.horizontalAccuracy <= 1000) {
            
            [self.locationManager stopUpdatingLocation];
            
            [[Mixpanel sharedInstance] track:@"set current location" ];
            
            NSURL *urlOverwrite = [NSURL URLWithString:[ NSString stringWithFormat: @"http://pbsmartlab.com/mymovemobile/localdeals_native?latlng=%f,%f", location.coordinate.latitude,location.coordinate.longitude]];
            NSURLRequest *request = [NSURLRequest requestWithURL:urlOverwrite];
            NSLog(@"in location manager %@",urlOverwrite);
            [self.webView loadRequest:request];
            
            NSString *currentLocationString = [NSString stringWithFormat:@"setCurrentLocation(%f,%f)",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude];
            [self.webView stringByEvaluatingJavaScriptFromString:currentLocationString];
            
            //log last seen location
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
            [PFUser currentUser][@"lastLocation"]=point;
            [[PFUser currentUser] saveInBackground];
            
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
    NSLog(@"herere!!! %@",key);
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
}
@end
