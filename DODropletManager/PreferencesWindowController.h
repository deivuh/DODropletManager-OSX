***REMOVED***
***REMOVED***  PreferencesWindowController.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate> {
    
    IBOutlet NSTableView *sshUsersTableview;
}

@property (weak) IBOutlet NSTextField *ClientIDTF;
@property (weak) IBOutlet NSTextField *APIKeyTF;
@property (weak) IBOutlet NSTextField *statusLB;


@property (weak) IBOutlet NSButton *launchAtLoginCB;

<<<<<<< HEAD
@property (weak) IBOutlet NSButton *iTermCB;


- (BOOL) checkiTerm;


=======
@property (weak) IBOutlet NSTextField *versionLabel;
>>>>>>> a9e51a8892324a32170949e8161e6a25184cd3a8


@end
