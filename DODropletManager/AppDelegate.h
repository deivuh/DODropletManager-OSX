//
//  AppDelegate.h
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "PreferencesWindowController.h"
#import <Cocoa/Cocoa.h>

@class DropletFormWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableData *responseData;
    NSMutableArray *dropletsArray;
    
    NSURLConnection *dropletsConnection, *regionsConnection, *imagesConnection;
    
    NSURLConnection *rebootDropletConnection, *shutdownDropletConnection, *turnOnDropletConnection;
    
    NSString *clientID, *APIKey;
    
    NSMutableDictionary *regions;
    NSMutableDictionary *images;
    
    NSUserDefaults *userDefaults;

    
    NSMenuItem *refreshMI;
    
    BOOL firstRun;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong) PreferencesWindowController *preferencesWC;
@property (strong, nonatomic) DropletFormWindowController *dropletFormWindowController;

@end
