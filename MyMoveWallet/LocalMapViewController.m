//
//  LocalMapViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/16/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "LocalMapViewController.h"
#import "MapViewAnnotation.h"
#import "DMWebBrowserViewController.h"
@interface LocalMapViewController ()

@end

@implementation LocalMapViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"local deals: %@",self.localDeals);
    [self initializeMap];
    [self dropPins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(IBAction)goBack{
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapView:(MKMapView *) mapView annotationView: (MKAnnotationView *)view calloutAccessoryControlTapped: (UIControl *) control {
    MapViewAnnotation *newAnnotation = (MapViewAnnotation*)[view annotation];
    //NSLog(@"link: %@",newAnnotation.link );
    DMWebBrowserViewController *webBrowser = [[DMWebBrowserViewController alloc]
                                              initWithURL:[NSURL URLWithString:newAnnotation.link]
                                              startLoadingWithBlock:^{
                                                 // NSLog(@"start loading web browser page");
                                              } andEndLoadingWithBlock:^{
                                                  //NSLog(@"end loading web browser page");
                                              }];
    //[webBrowser setNavBarColor:[UIColor orangeColor]];
    //webBrowser.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:webBrowser animated:YES completion:nil];
}


-(void)dropPins{
    
    NSMutableArray* dealLocations = [[NSMutableArray alloc] init];
    
    for(NSDictionary* localDeal in self.localDeals){
        CLLocationCoordinate2D businessCenter;
        businessCenter.latitude = [[[localDeal objectForKey:@"merchant"] objectForKey:@"latitude"] doubleValue];
        businessCenter.longitude = [[[localDeal objectForKey:@"merchant"] objectForKey:@"longitude"] doubleValue];
        //add annotation
        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[[localDeal objectForKey:@"merchant"] objectForKey:@"name" ] andCoordinate:businessCenter];
        newAnnotation.link =[[localDeal objectForKey:@"deal"] objectForKey:@"link" ];
        [self.mapView addAnnotation:newAnnotation ];
        
        [dealLocations addObject:newAnnotation];
        
    }
    
    
    
    MKCoordinateRegion region = [self regionForAnnotations:dealLocations];
    [self.mapView setRegion:region animated:YES];
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
        
        const double extraSpace = 1.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}

@end
