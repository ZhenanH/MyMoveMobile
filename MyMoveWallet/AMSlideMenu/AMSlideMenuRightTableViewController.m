//
//  AMSlideMenuRightTableViewController.m
//  AMSlideMenu
//
// The MIT License (MIT)
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "AMSlideMenuRightTableViewController.h"

#import "AMSlideMenuMainViewController.h"

#import "AMSlideMenuContentSegue.h"
#import <Parse/Parse.h>
@interface AMSlideMenuRightTableViewController ()

@end

@implementation AMSlideMenuRightTableViewController

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.couponUpdateSwitch addTarget:self action:@selector(updateChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.locationBaseCouponSwitch addTarget:self action:@selector(locationCouponChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)openContentNavigationController:(UINavigationController *)nvc
{
#ifdef AMSlideMenuWithoutStoryboards
    AMSlideMenuContentSegue *contentSegue = [[AMSlideMenuContentSegue alloc] initWithIdentifier:@"contentSegue" source:self destination:nvc];
    [contentSegue perform];
#else
    NSLog(@"This methos is only for NON storyboard use! You must define AMSlideMenuWithoutStoryboards \n (e.g. #define AMSlideMenuWithoutStoryboards)");
#endif
}

/*----------------------------------------------------*/
#pragma mark - TableView delegate -
/*----------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mainVC respondsToSelector:@selector(navigationControllerForIndexPathInRightMenu:)]) {
        UINavigationController *navController = [self.mainVC navigationControllerForIndexPathInRightMenu:indexPath];
        AMSlideMenuContentSegue *segue = [[AMSlideMenuContentSegue alloc] initWithIdentifier:@"ContentSugue" source:self destination:navController];
        //[segue perform];
    } else {
        NSString *segueIdentifier = [self.mainVC segueIdentifierForIndexPathInRightMenu:indexPath];
        if (segueIdentifier && segueIdentifier.length > 0)
        {
            //[self performSegueWithIdentifier:segueIdentifier sender:self];
        }
    }
}

- (void)updateChanged:(UISwitch *)switchState
{
    
    

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    if ([switchState isOn]) {
        NSLog(@"On");
        NSLog(@"enableing push");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
        [currentInstallation addUniqueObject:@"new_coupon_update" forKey:@"channels"];
        NSDictionary *dimensions = @{
                                     @"event":@"on"
                                     };
        [PFAnalytics trackEvent:@"notify_update_coupon" dimensions:dimensions];
    } else {
        NSLog(@"Off");
        NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
        NSLog(@"%@",subscribedChannels);
        if([subscribedChannels containsObject:@"new_coupon_update"]){
             [currentInstallation removeObject:@"new_coupon_update" forKey:@"channels"];
        }
        NSDictionary *dimensions = @{
                                     @"event":@"off"
                                     };
        [PFAnalytics trackEvent:@"notify_update_coupon" dimensions:dimensions];
        
    }
    [currentInstallation saveInBackground];
}

- (void)locationCouponChanged:(UISwitch *)switchState
{

    if ([switchState isOn]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coming soon!"
                                                        message:@"Thank you for your interested in this feature, we are working hard on it."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [switchState setOn:NO animated:YES];
        NSDictionary *dimensions = @{
                                    @"event":@"try"
                                     };
        [PFAnalytics trackEvent:@"location_base_coupon" dimensions:dimensions];
    } else {
        NSLog(@"Off");
    }
}

-(BOOL)isEnabledPush{
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone)
        return NO;
    else
        return YES;
}

@end
