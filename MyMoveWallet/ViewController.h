//
//  ViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 5/30/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
#import "URLConnection.h"
@interface ViewController : CDVViewController<UIWebViewDelegate,CLLocationManagerDelegate,URLConnectionDelegate,POIListDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end
