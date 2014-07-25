//
//  NearByStoresViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/21/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "NearByStoresViewController.h"
#import "Mixpanel.h"
#import "MapViewAnnotation.h"
@interface NearByStoresViewController ()

@end

@implementation NearByStoresViewController{
    CLLocation *location;
    NSURLConnection *connection;
    NSMutableData *jsonData;
    NSDictionary *jsonDict;
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
    [self initializeMap];
    [self initializeLocationManager];
    [self initializeLocationUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeMap {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.mapView.delegate = self;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
        view.lineWidth=1;
        view.strokeColor=[UIColor blueColor];
        view.fillColor=[[UIColor cyanColor] colorWithAlphaComponent:0.3];
        return view;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annoView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:@"current"];
    annoView.animatesDrop = YES;
    annoView.canShowCallout = YES;
    annoView.rightCalloutAccessoryView =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annoView;
}

-(void)dropPins{
    
    NSMutableArray* storeLocations = [[NSMutableArray alloc] init];
    
    for(NSDictionary* store in [jsonDict objectForKey:@"Output"]){
        CLLocationCoordinate2D businessCenter;
        businessCenter.latitude = [[store objectForKey:@"Latitude"] doubleValue];
        businessCenter.longitude = [[store objectForKey:@"Longitude"] doubleValue];
        //add annotation
        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@, %@, %@ ", [store objectForKey:@"Name"],[store objectForKey:@"Street"],[store objectForKey:@"City"] ]  andCoordinate:businessCenter];
        //newAnnotation.link =[[store objectForKey:@"deal"] objectForKey:@"link" ];
        [self.mapView addAnnotation:newAnnotation ];
        
        [storeLocations addObject:newAnnotation];
        
    }
     MapViewAnnotation *currentLocation = [[MapViewAnnotation alloc] initWithTitle:@"" andCoordinate:location.coordinate];
    [storeLocations addObject:currentLocation];
    
    MKCoordinateRegion region = [self regionForAnnotations:storeLocations];
    [self.mapView setRegion:region animated:YES];
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
            // use location to query
            
            [self refreshSearch];

            jsonData = [[NSMutableData alloc]init];
            
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

-(void)connection:(NSURLConnection*)conn didReceiveData:(NSData *)data
{
    [jsonData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)conn
{
    
    NSError *error = nil;
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:kNilOptions
                                                 error:&error];
    NSLog(@"%@", jsonDict);
    if([[jsonDict objectForKey:@"Output"] count]>0 && ![[[[jsonDict objectForKey:@"Output"] objectAtIndex:0] objectForKey:@"Status"] isEqualToString:@"F"]){
        [self dropPins];
    }else{
        [self showAlertWithMessage:@"No result found nearby" :@"Please try search larger area"];
    }
    [self.refreshButton setEnabled:YES];
    [self.loading stopAnimating];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
    MKCoordinateRegion region;
    
    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
        
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
        
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 2.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}

- (IBAction)sliderValueChanged:(UISlider *)sender{
    self.radiusLabel.text = [NSString stringWithFormat:@"%.1f miles", roundf([sender value])];
}

- (IBAction) refreshSearch{
    [self.refreshButton setEnabled:NO];
    NSString* apiUrl = [NSString stringWithFormat: @"http://75.101.129.49/rest/MerchantLocatorByName/results.json?Data.lat=%f&Data.lon=%f&Data.poi_name=%@&Data.radius=%.0f",location.coordinate.latitude,location.coordinate.longitude, self.brandName,roundf(self.radiusSlider.value) ];
    NSLog(@"url: %@",apiUrl);
    NSURL *url = [NSURL URLWithString:[apiUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] ;
    NSLog(@"url: %@",url);
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    // NSLog(@"url2: %@",url);
    jsonData = [[NSMutableData alloc]init];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    [self.loading startAnimating];
}

@end
