//
//  AppDelegate.m
//  DisplayPh
//
//  Created by Nigel Crawley on 08/12/2014.
//  Copyright (c) 2014 Nigel Crawley. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString *xml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jsondecoder" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]; // load local svg file
    // construct code to load into web view
    [[_parserWebView mainFrame] loadData:[xml dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil]; // load SVG display file
    
    // setup request ///
    NSURL *appUrl = [NSURL URLWithString:@"http://incredibleaquagdn.no-ip.info:8003/todmorden?category=pH&limit=1&callback=displayValue"];
    //NSURL *appUrl = [NSURL URLWithString:@"http://localhost/~nigelcrawley/demo-ph.php"]; // test app url
    _request = [NSURLRequest requestWithURL:appUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    // END request setup ///
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:@"(🐟...)"]; // initial loading indicator
    
    [self updateApp]; // first update
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (void)updateApp // get latest ph data
{
    [[_webView mainFrame] loadRequest:_request]; // load request for data
}

-(IBAction)openUrl:(id)sender // open the Incredible Aquagarden dashboard in default web browser
{
    //NSLog(@"going to url");
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://incredibleaquagdn.no-ip.info/?load=dashboard.json"]];
}

- (IBAction)callUpdate:(id)sender
{
    [statusItem setTitle:@"(🐟...)"]; // show loading indicator
    [self updateApp];
}

#pragma mark - WebView Delegate Methods
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    //NSLog(@"Updating");
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // stop timer
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }

    NSString *jsonData = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
    
    NSString *jsonDataFunction = [NSString stringWithFormat:@"updateDisplay(%@)", jsonData]; // make update function
    // run javascript function on displayView contents
    NSString *returnedValue = [_parserWebView stringByEvaluatingJavaScriptFromString:jsonDataFunction];

    // process returned data from javascript function
    NSArray *returnedArray = [returnedValue componentsSeparatedByString:@","];
    
    [statusItem setToolTip:[NSString stringWithFormat:@"Updated: %@", [returnedArray firstObject]]];
    [statusItem setTitle:[NSString stringWithFormat:@"(🐟 %@)", [returnedArray lastObject]]];
    
    //NSLog(@"%@",returnedValue);
    
    //NSLog(@"%@",jsonData);

    // start new timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:(60 * 15) target:self selector:@selector(updateApp) userInfo:nil repeats:YES];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    // stop old timer
    if (_timer != nil)
    {
        [_timer invalidate];
        _timer = nil;
    }

    [statusItem setTitle:@"(🐟???)"]; // show error happened

    // start new timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:(60 * 15) target:self selector:@selector(updateApp) userInfo:nil repeats:YES];
}

@end
