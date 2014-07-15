//
//  InfoViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/9/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <Cordova/CDVViewController.h>

@interface InfoViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;

@end
