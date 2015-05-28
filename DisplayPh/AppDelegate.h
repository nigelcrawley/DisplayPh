//
//  AppDelegate.h
//  DisplayPh
//
//  Created by Nigel Crawley on 08/12/2014.
//  Copyright (c) 2014 Nigel Crawley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
}

@property (weak) IBOutlet WebView *webView;

@property (weak) IBOutlet WebView *parserWebView;

@property (strong) NSURLRequest *request;

@property (strong) NSTimer *timer;

- (IBAction)openUrl:(id)sender;
- (IBAction)callUpdate:(id)sender;

- (void)updateApp;


@end

