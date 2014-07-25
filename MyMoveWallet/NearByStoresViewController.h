//
//  NearByStoresViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/21/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface NearByStoresViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) NSDictionary *localDeals;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *brandName;
-(IBAction) back;

- (IBAction) sliderValueChanged:(UISlider *)sender;
- (IBAction) refreshSearch;
@property (strong, nonatomic) IBOutlet UILabel *radiusLabel;
@property (strong, nonatomic) IBOutlet UISlider *radiusSlider;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end
