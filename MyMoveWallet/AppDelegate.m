//
//  AppDelegate.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 5/30/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "RootViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "Mixpanel.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"NfzjaOxENPzKYkqKogb6gc0yNqQmS7rGqZ3N3rn5"
                  clientKey:@"0cNTK9ZHS3fic2aQBuT80xg9ejY8wKPeOUHSxHrA"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[Mixpanel sharedInstanceWithToken:@"be78fcacdeae95626e6582fa62d4662f"];//real
    [Mixpanel sharedInstanceWithToken:@"be78fcacdeae95626e6582fa62d4662ff"];//fake

    
    //generate unique user id
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    if(![userDefaults objectForKey:@"UUID"]){
        NSLog(@"creating uuid...");
        [userDefaults setObject:[NSString stringWithFormat:@"ID_%@",[[NSUUID UUID] UUIDString] ] forKey:@"UUID"];
        [userDefaults synchronize];
        
        
        //segment users
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addObject:@"PB" forKey:@"channels"];
        [currentInstallation addObject:[userDefaults objectForKey:@"UUID"] forKey:@"channels"];
        [currentInstallation addObject:@"new_coupon_update" forKey:@"channels"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                NSLog(@"SAVED!!");
            }
        }
         ];
    }else{
        NSLog(@"UUID already created@");
    }

    //push
    // Register for push notifications

    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];

    
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"RunCount"];

                                            
    PFACL *defaultACL = [PFACL ACL];
    // Optionally enable public read access while disabling public write access.
    // [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        //not sign up yet
        PFUser *user = [PFUser user];
        user.username = [userDefaults objectForKey:@"UUID"];
        user.password = @"";
        
        
        // other fields can be set just like with PFObject
        //user[@"phone"] = @"415-392-0202";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Hooray! Let them use the app now.
                [PFUser logInWithUsernameInBackground:user.username password:@""
                                                block:^(PFUser *user, NSError *error) {
                                                    if (user) {
                                                        // Do stuff after successful login.
                                                    } else {
                                                        // The login failed. Check error to see why.
                                                    }
                                                }];
                
            } else {
                //NSString *errorString = [error userInfo][@"error"];
                                // Show the errorString somewhere and let the user try again.
            }
        }];
    } else {
        NSLog(@"did not sign up agian");
        
    }
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"register for push!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    RootViewController* rvc =[[navigationController viewControllers] objectAtIndex:0];
    if([rvc isUpdateAvailable])
        {
            
            
            [[rvc rightMenu].updateButton setEnabled:YES];
            BBBadgeBarButtonItem *updateButton =[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:[rvc rightMenu].updateButton];
            updateButton.badgeValue = @"1";
            updateButton.badgeOriginX = -25;
            updateButton.badgeOriginY = 5;
            updateButton.badgeMinSize = 3;
            [updateButton shouldHideBadgeAtZero];
            [[rvc rightMenu].updateText setText:@"Update available"];
            NSLog(@"updating from app delegate");
        }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    // ...
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
