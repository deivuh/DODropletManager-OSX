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
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong) PreferencesWindowController *preferencesWC;

@end
