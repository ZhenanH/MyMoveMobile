//
//  GeoFenceSettingViewController.h
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/22/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoFenceSettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
-(IBAction)back;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(readonly, nonatomic) NSSet *monitoredRegions;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableDictionary* reminderGroups;
@end
