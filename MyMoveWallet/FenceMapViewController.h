//
//  FenceMapViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/22/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface FenceMapViewController : UIViewController<MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
-(IBAction)back;
@property (strong, nonatomic) NSArray *fences;
@end
