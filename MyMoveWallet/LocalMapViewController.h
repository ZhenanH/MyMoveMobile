//
//  LocalMapViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/16/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface LocalMapViewController : UIViewController<MKMapViewDelegate>
@property (strong, nonatomic) NSDictionary *localDeals;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
-(IBAction)goBack;
@end
