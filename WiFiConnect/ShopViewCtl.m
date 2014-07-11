//
//  ShopViewCtl.m
//  WiFiConnect
//
//  Created by IOS on 14-7-9.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "ShopViewCtl.h"

@interface ShopViewCtl ()

@end

@implementation ShopViewCtl

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
    [self loadWebView];
    // Do any additional setup after loading the view.
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

#pragma mark -
#pragma mark webview
- (void)loadWebView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    path = @"http://www.baidu.com";
    
    NSURL* url = [NSURL URLWithString:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}




#pragma mark -
#pragma mark IBAction
- (IBAction)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:NO];
    
}

@end
