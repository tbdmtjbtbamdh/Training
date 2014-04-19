//
//  WebViewController.m
//  TwitterClient01
//
//  Created by 09support02 on 2014/04/19.
//  Copyright (c) 2014年 09support02. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController

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
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:self.openURL];
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
