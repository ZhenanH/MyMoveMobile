//
//  FenceMapViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/22/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "FenceMapViewController.h"
#import "MapViewAnnotation.h"

@interface FenceMapViewController ()

@end

@implementation FenceMapViewController

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
    [self dropPins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSMutableArray* dealLocations = [[NSMutableArray alloc] init];
    
    for(NSDictionary* localStore in self.fences){
        CLLocationCoordinate2D businessCenter = ((CLCircularRegion *)localStore).center;

        //add annotation
        MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:((CLCircularRegion *)localStore).identifier  andCoordinate:businessCenter];

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
        
        const double extraSpace = 2.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}



@end
