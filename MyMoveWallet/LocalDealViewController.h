//
//  LocalDealViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/7/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <Cordova/CDVViewController.h>

@interface LocalDealViewController : UIViewController<UIWebViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end
