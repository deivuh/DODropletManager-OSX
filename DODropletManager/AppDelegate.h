***REMOVED***
***REMOVED***  AppDelegate.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "PreferencesWindowController.h"
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableData *responseData;
    NSMutableArray *dropletsArray;
    
    NSURLConnection *dropletsConnection, *regionsConnection, *imagesConnection;
    
    NSString *clientID, *APIKey;
    
    NSMutableDictionary *regions;
    NSMutableDictionary *images;
    
    NSUserDefaults *userDefaults;

}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong) PreferencesWindowController *preferencesWC;

@end
