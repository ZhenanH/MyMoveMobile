//
//  RootViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 6/12/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "RootViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "DMWebBrowserViewController.h"
#import "Mixpanel.h"
@implementation RootViewController{
    BOOL updateAvailable;
    BBBadgeBarButtonItem *barButton;
    BBBadgeBarButtonItem *updateButton;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    
}

-(NSString*)segueIdentifierForIndexPathInRightMenu:(NSIndexPath *)indexPath{
    NSString* identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"MainPage";
            break;
        case 1:
            identifier = @"MainPage";
            break;
            
        default:
            break;
    }
    return  identifier;
}

-(NSString*)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath{
    NSString* identifier;
    switch (indexPath.row) {
        case 0:
            identifier = @"MainPage";
            break;
        case 1:
            identifier = @"MainPage";
            break;
        case 2:
            identifier = @"LocalDeals";
            break;
        case 3:
            identifier = @"howTo";
            break;
        default:
            break;
    }
    return  identifier;
}

- (AMPrimaryMenu)primaryMenu{
    return AMPrimaryMenuRight;
};

- (CGFloat)panGestureWarkingAreaPercent{
    return 0;
}

-(void)configureLeftMenuButton:(UIButton *)button{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){32,32};
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"menu2.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(menubuttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    
    

}

-(void)configureRightMenuButton:(UIButton *)button{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){32,32};
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    
    AMSlideMenuRightTableViewController* rightMenu = [self rightMenu];
    [rightMenu.updateButton addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    // Set a value for the badge
    if([self isUpdateAvailable]){
    
    barButton.badgeValue = @"1";
    barButton.badgeOriginX = 25;
    barButton.badgeOriginY = 0;
    barButton.badgeMinSize = 10;
    [barButton shouldHideBadgeAtZero];
        
        [rightMenu.updateButton setEnabled:YES];

        updateButton =[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:rightMenu.updateButton];
        updateButton.badgeValue = @"1";
        updateButton.badgeOriginX = -25;
        updateButton.badgeOriginY = 5;
        updateButton.badgeMinSize = 3;
        [updateButton shouldHideBadgeAtZero];
        [rightMenu.updateText setText:@"Update available"];
        
       // [self.locationBaseCouponSwitch addTarget:self action:@selector(locationCouponChanged:) forControlEvents:UIControlEventValueChanged];
    }

    // Add it as the leftBarButtonItem of the navigation bar
   // self.navigationItem.leftBarButtonItem = barButton;
}

-(BOOL)isUpdateAvailable{
    updateAvailable = NO;
    NSDictionary *updateDictionary = [NSDictionary dictionaryWithContentsOfURL:
                                      [NSURL URLWithString:@"http://mymove.parseapp.com/plist/MyMoveWallet.plist"]];
    
    if(updateDictionary)
    {
        NSArray *items = [updateDictionary objectForKey:@"items"];
        NSDictionary *itemDict = [items lastObject];
        
        NSDictionary *metaData = [itemDict objectForKey:@"metadata"];
        NSString *newversion = [metaData valueForKey:@"bundle-version"];
        NSString *currentversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        updateAvailable = [newversion compare:currentversion options:NSNumericSearch] == NSOrderedDescending;
        
    }
   
    return updateAvailable;
}

-(void)buttonTapped:(UIButton*)button{
    [[Mixpanel sharedInstance] track:@"configure button clicked" ];
    barButton.badgeValue = @"0";
}

-(void)menubuttonTapped:(UIButton*)button{
    [[Mixpanel sharedInstance] track:@"menu button clicked" ];
}

-(void)updateButtonTapped:(UIButton*)button{
    //updateButton.badgeValue = @"0";
   // UIWebView *webView = [[UIWebView alloc] init];
    //[webView setFrame:CGRectMake(0, 0, 320, 460)];
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http:/pbsmartlab.com/mymove/download.html"]]];
   // [[self view] addSubview:webView];
    DMWebBrowserViewController *webBrowser = [[DMWebBrowserViewController alloc]
                                              initWithURL:[NSURL URLWithString:@"http://pbsmartlab.com/mymove/update.html"]
                                              startLoadingWithBlock:^{
                                                  NSLog(@"start loading web browser page");
                                              } andEndLoadingWithBlock:^{
                                                  NSLog(@"end loading web browser page");
                                              }];
    //[webBrowser setNavBarColor:[UIColor orangeColor]];
    [self presentViewController:webBrowser animated:YES completion:nil];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http:/pbsmartlab.com/mymove/update.html"]];
}
@end
