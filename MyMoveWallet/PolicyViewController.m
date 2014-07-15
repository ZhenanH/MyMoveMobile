//
//  PolicyViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/11/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "PolicyViewController.h"

@interface PolicyViewController ()

@end

@implementation PolicyViewController
{
    int webViewLoads;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    webViewLoads = 0;
    
    NSURL *urlOverwrite = [NSURL URLWithString:[ NSString stringWithFormat: @"http://localhost:3000/mymovemobile/policy"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlOverwrite];
    NSLog(@"in location manager %@",urlOverwrite);
    [self.webView loadRequest:request];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    webViewLoads++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    webViewLoads--;

    if (webViewLoads > 0) {
        return;
    }
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
