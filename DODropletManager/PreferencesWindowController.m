//
//  PreferencesWindowController.m
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController


- (id)init {
    self=[super initWithWindowNibName:@"PreferencesWindow"];
    if(self)
    {
        //perform any initializations
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)savePreferences:(id)sender {
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:_ClientIDTF.stringValue forKey:@"clientID"];
    [userDefaults setObject:_APIKeyTF.stringValue forKey:@"APIKey"];
    
    [userDefaults synchronize];
}


@end
