//
//  InfoViewController.m
//  MyMoveWallet
//
//  Created by Zhenan Hong on 7/9/14.
//  Copyright (c) 2014 Lean Develop. All rights reserved.
//

#import "InfoViewController.h"
#import "DMWebBrowserViewController.h"
@interface InfoViewController ()

@end

@implementation InfoViewController
{
int webViewLoads;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = (id)self;
    // Do any additional setup after loading the view.
    webViewLoads = 0;
    
    NSURL *urlOverwrite = [NSURL URLWithString:[ NSString stringWithFormat: @"http://www.mymove.com/resources/moving.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlOverwrite];
    NSLog(@"in location manager %@",urlOverwrite);
    [self.webView loadRequest:request];
    [self.loading startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    webViewLoads++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    webViewLoads--;
    [self.loading stopAnimating];
    if (webViewLoads > 0) {
        return;
    }
    webView.scrollView.contentOffset = CGPointMake(0, 120);
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    webViewLoads--;

    if (webViewLoads > 0) {
        return NO;
    }
    if ( navigationType == UIWebViewNavigationTypeLinkClicked )
    {
        //[[UIApplication sharedApplication] openURL:[request URL]];
        [self.loading startAnimating];
        return YES;
    }
    return YES;
}

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    
}


@end
