//
//  GeoFenceSettingViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/22/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "GeoFenceSettingViewController.h"
#import "POIList.h"
#import "FenceMapViewController.h"
@interface GeoFenceSettingViewController ()

@end

@implementation GeoFenceSettingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeLocationManager];
    
    //re-organize the geofence lists
    self.reminderGroups = [[NSMutableDictionary alloc] init];
    for(int i=0;i< [[self.locationManager monitoredRegions] count];i++)
    {
        NSString* key = [[[[[[self.locationManager monitoredRegions] allObjects] objectAtIndex:i ] identifier] componentsSeparatedByString:@";"] objectAtIndex:0];
        if([self.reminderGroups objectForKey:key]){
            NSMutableArray* tempReminders=[self.reminderGroups objectForKey:key];
            [tempReminders addObject: [[[self.locationManager monitoredRegions] allObjects] objectAtIndex:i]];
           
        }else{
            NSMutableArray* tempReminders = [[NSMutableArray alloc] initWithObjects:[[[self.locationManager monitoredRegions] allObjects] objectAtIndex:i ], nil];
            [self.reminderGroups setObject:tempReminders forKey:key];
        }
    }
    
   // NSLog(@"monitored regions: %@",self.reminderGroups);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    NSLog(@"location enable: %d",[CLLocationManager locationServicesEnabled]);
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"Location Services Error" : @"You need to enable location services to do location search."];
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.reminderGroups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableCell"];
    }
    
    
    cell.textLabel.text =[[self.reminderGroups allKeys] objectAtIndex:indexPath.row];
    UISwitch *geoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 5, 0, 0)];
    [geoSwitch setOn:YES];
    [cell addSubview:geoSwitch];
    

    
    return cell;
}






-(IBAction)back{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertWithMessage:(NSString*)title :(NSString*)alertText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"fenceMap"]){
    FenceMapViewController* targetVC = (FenceMapViewController*)segue.destinationViewController;
        targetVC.fences = [[self.reminderGroups allValues] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}
@end
