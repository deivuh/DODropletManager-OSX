***REMOVED***
***REMOVED***  PreferencesWindowController.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSUserDefaults *userDefaults;
    
    NSMutableData *responseData;
}

@property (strong) IBOutlet NSTextField *ClientIDTF;
@property (strong) IBOutlet NSTextField *APIKeyTF;
@property (weak) IBOutlet NSTextField *statusLB;




@end
