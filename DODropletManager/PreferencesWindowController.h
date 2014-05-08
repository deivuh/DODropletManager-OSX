//
//  PreferencesWindowController.h
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate> {
    
    IBOutlet NSTableView *sshUsersTableview;
}

@property (strong) IBOutlet NSTextField *ClientIDTF;
@property (strong) IBOutlet NSTextField *APIKeyTF;
@property (weak) IBOutlet NSTextField *statusLB;


@property (weak) IBOutlet NSButton *launchAtLoginCB;



@end
