//
//  AppDelegate.m
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "AppDelegate.h"
#import "Droplet.h"
#import "KeychainAccess.h"
#import "DropletFormWindowController.h"
#import "DropletManager.h"
#import "iTerm.h"


@implementation AppDelegate {
    

    NSUserDefaults *userDefaults;
    
    NSMenuItem *refreshMI;
    NSAlert *rebootAlert, *shutdownAlert, *deleteConfirmAlert;
    
    NSTimer *refreshingTimer;
    
    
    float fade, delta;
    
    BOOL firstRun;
    
    DropletManager *dropletManager;
    
    NSUserDefaults *userdefaults;
    NSMutableDictionary *sshUserDictionary;
    NSMutableDictionary *sshPortDictionary;
    
    iTermITermApplication *iTerm;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    
    
    dropletManager = [DropletManager sharedManager];
    
    
    
    [self createMenuItems];
    
    if(dropletManager.accessToken) {
        [self refresh: self];
    } else {
        [self showPreferencesWindow: self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"dropletsLoaded"
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"dropletsFailed"
                                               object:nil];

    
    userdefaults = [NSUserDefaults standardUserDefaults];
    
    
    //    If dictionary exists, load it from userDefaults;
    if ([userdefaults objectForKey:@"sshUserDictionary"] == nil) {
        sshUserDictionary = [[NSMutableDictionary alloc] init];
    } else {
        sshUserDictionary = [[userdefaults objectForKey:@"sshUserDictionary"] mutableCopy];
    }
    
    //    If dictionary exists, load it from userDefaults;
    if ([userdefaults objectForKey:@"sshPortDictionary"] == nil) {
        sshPortDictionary = [[NSMutableDictionary alloc] init];
    } else {
        sshPortDictionary = [[userdefaults objectForKey:@"sshPortDictionary"] mutableCopy];
    }
    
    //Check for iTerm config default
    if([userDefaults valueForKey:@"iTerm"] == nil) {
        [userDefaults setValue:[NSNumber numberWithBool:NO] forKey:@"iTerm"];
        [userdefaults synchronize];
    }
    
    
    
    
    
    
}



- (BOOL)loadKeys {

        
    return NO;

}

#pragma mark -
#pragma mark Menu methods

- (void) setStatusImage:(NSString*)name {
    if(refreshingTimer) {
        [refreshingTimer invalidate];
        refreshingTimer = nil;
    }
    
    _statusItem.image = [NSImage imageNamed: name];
}

- (void) createMenuItems {

    NSMenu *menu;
    BOOL addItems;
    if(_statusItem == nil) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        
        _statusItem.title = @"";
        _statusItem.alternateImage = [NSImage imageNamed:@"dropletStatusIconHighlightedTemplate"];
        _statusItem.highlightMode = YES;
        menu = [[NSMenu alloc] init];
        addItems = YES;
    } else {
        menu = _statusItem.menu;
        addItems = NO;
        
        while(![[menu itemAtIndex: 0] isSeparatorItem]) {
            [menu removeItemAtIndex: 0];
        }
    }
    
    [self setStatusImage: @"dropletStatusIconTemplate"];
    
    int dropletMIIndex = 0;
    
    for (Droplet *droplet in [dropletManager droplets]) {
        [menu insertItemWithTitle: droplet.name action: nil keyEquivalent: @"" atIndex: dropletMIIndex];

        NSMenu *submenu = [[NSMenu alloc] init];
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Status: %@", [droplet.status capitalizedString]]
                           action:nil
                    keyEquivalent:@""];


        NSMenuItem *ipAddressMI = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"IP: %@", droplet.ip] action:@selector(copyIPAddress:) keyEquivalent:@""];
        
        [ipAddressMI setRepresentedObject:droplet.ip];
        
        [submenu addItem:ipAddressMI];
        
        if (droplet.distro != nil) {
            [submenu addItemWithTitle:[NSString stringWithFormat:@"Image: %@", droplet.distro]
                               action:nil
                        keyEquivalent:@""];
        }
        

        
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Region: %@", droplet.region]
                           action:nil
                    keyEquivalent:@""];
        
        [submenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *viewOnWebMI = [[NSMenuItem alloc] initWithTitle:@"View on website" action:@selector(viewDropletOnBrowser:) keyEquivalent:@""];
        
        [viewOnWebMI setImage:[NSImage imageNamed:@"infoIconTemplate"]];
        [viewOnWebMI setRepresentedObject:droplet];
        
        [submenu addItem:viewOnWebMI];
        
        NSMenuItem *connectToDroplet = [[NSMenuItem alloc] initWithTitle:@"Connect to Droplet" action:@selector(establishSSHConnectionToDroplet:) keyEquivalent:@""];
        
        [connectToDroplet setImage:[NSImage imageNamed:@"sshIconTemplate"]];
        [connectToDroplet setRepresentedObject:droplet];
        
        [submenu addItem:connectToDroplet];
        
        NSMenuItem *rebootMI = [[NSMenuItem alloc] initWithTitle:@"Reboot" action:@selector(confirmReboot:) keyEquivalent:@""];
        
        [rebootMI setImage:[NSImage imageNamed:@"rebootIconTemplate"]];
        [rebootMI setRepresentedObject:droplet];
        
        [submenu addItem:rebootMI];
        
        if (droplet.active) {
            NSMenuItem *shutdownMI = [[NSMenuItem alloc] initWithTitle:@"Shutdown" action:@selector(confirmShutdown:) keyEquivalent:@""];
            
            [shutdownMI setImage:[NSImage imageNamed:@"powerIconTemplate"]];
            [shutdownMI setRepresentedObject:droplet];
            
            [submenu addItem:shutdownMI];
            
        } else {

            NSMenuItem *turnOnMI = [[NSMenuItem alloc] initWithTitle:@"Power On" action:@selector(turnOnDroplet:) keyEquivalent:@""];
            [turnOnMI setImage:[NSImage imageNamed:@"powerIconTemplate"]];
            [turnOnMI setRepresentedObject:droplet];
        
            [submenu addItem:turnOnMI];
        }
        
        NSMenuItem *deleteDropletMI = [[NSMenuItem alloc] initWithTitle:@"Delete Droplet" action:@selector(confirmDropletDeletion:) keyEquivalent:@""];
        
        [deleteDropletMI setImage:[NSImage imageNamed:@"trashIconTemplate"]];
        [deleteDropletMI setRepresentedObject:droplet];
        
        [submenu addItem:deleteDropletMI];
        
        [menu setSubmenu:submenu forItem:[menu.itemArray objectAtIndex:dropletMIIndex]];
        dropletMIIndex ++;
        
    }
    
    [menu insertItemWithTitle:@"Create New Droplet" action:@selector(showDropletFormUI) keyEquivalent:@"" atIndex:dropletMIIndex];
    
    if(addItems) {
        [menu addItem:[NSMenuItem separatorItem]];
        
        refreshMI = [[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Refresh", @"Refresh") action:@selector(refresh:) keyEquivalent:@""];
        [menu addItem:refreshMI];
        
        [menu addItemWithTitle: NSLocalizedString(@"Preferences", @"Preferences") action:@selector(showPreferencesWindow:) keyEquivalent:@""];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        [menu addItemWithTitle: NSLocalizedString(@"Quit Droplets Manager", @"Quit Droplets Manager") action:@selector(terminate:) keyEquivalent:@""];
        _statusItem.menu = menu;
    }
}

#pragma mark -
#pragma mark Menu actions

- (void)copyIPAddress:(id)sender {
    
    NSString *ipAddress = ((NSMenuItem*)sender).representedObject;
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:ipAddress forType:NSStringPboardType];
}

- (void)showDropletFormUI
{
    _dropletFormWindowController = [[DropletFormWindowController alloc] initWithWindowNibName:@"DropletFormWindow"];
    [_dropletFormWindowController showWindow:self];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)showPreferencesWindow:(id)sender {
    

    
    //Show preferences window
    _preferencesWC = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    [_preferencesWC showWindow:self];
    
    
    
    //Focus on window
    [NSApp activateIgnoringOtherApps:YES];
    
    
}

- (void)refresh:(id)sender {
    
  
    
    [self loadKeys];

    if(refreshingTimer == nil) {
        refreshingTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(refreshingTimerTick:) userInfo: nil repeats: YES];
        fade = 0;
        delta = 0.1;
    }
    
    refreshMI.title = NSLocalizedString(@"Refreshing...", @"Refreshing...");
    refreshMI.action = nil;
    [dropletManager refreshDroplets];
}

- (void)confirmReboot:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    rebootAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Reboot droplet", @"Reboot '%@'"), currentDroplet.name]
                                     defaultButton:NSLocalizedString(@"Ok", @"Ok")
                                   alternateButton:NSLocalizedString(@"Cancel", @"Cancel")
                                       otherButton:nil
                         informativeTextWithFormat:NSLocalizedString(@"Do you wish to proceed?", @"Do you wish to proceed?")];
    [rebootAlert beginSheetModalForWindow:[self window]
                      modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:(__bridge_retained void *)(currentDroplet)];
    
    
}


- (void)confirmShutdown:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    

    
    shutdownAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Shutdown droplet", @"Shutdown '%@'"), currentDroplet.name]
                                    defaultButton:NSLocalizedString(@"Ok", @"Ok")
                                  alternateButton:NSLocalizedString(@"Cancel", @"Cancel")
                                    otherButton:nil
                      informativeTextWithFormat:@"Do you wish to proceed?"];
    [shutdownAlert beginSheetModalForWindow:[self window]
                              modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:(__bridge_retained void *)(currentDroplet)];
    

}

- (void)confirmDropletDeletion:(id)sender
{
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    deleteConfirmAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Are you sure you want to delete '%@'? THIS CANNOT BE UNDONE", currentDroplet.name]
                                         defaultButton:@"Delete"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@""];
    
    [deleteConfirmAlert beginSheetModalForWindow:[self window]
                              modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:(__bridge_retained void *)(currentDroplet)];
}

- (void)rebootDroplet:(id)sender {
    
    Droplet *currentDroplet = (Droplet*)sender;
    
    [dropletManager rebootDroplet:currentDroplet];
    
}

- (void)shutdownDroplet:(id)sender {
    
    Droplet *currentDroplet = (Droplet*)sender;
    
    [dropletManager shutdownDroplet:currentDroplet];
}

- (void)turnOnDroplet:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    [dropletManager turnOnDroplet:currentDroplet];
}

- (void)viewDropletOnBrowser:(id)sender {
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloud.digitalocean.com/droplets/%@", currentDroplet.dropletID]]];
    
}

- (void)establishSSHConnectionToDroplet:(id)sender {
    


    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    
    if ([sshUserDictionary objectForKey:currentDroplet.name] == nil) {
        [sshUserDictionary setObject:@"root" forKey:currentDroplet.name];
    }
    if ([sshPortDictionary objectForKey:currentDroplet.name] == nil) {
        [sshPortDictionary setObject:@"22" forKey:currentDroplet.name];
    }
    
    NSString *dropletSSHUsername = [sshUserDictionary objectForKey:currentDroplet.name];
    NSString *dropletSSHPort = [sshPortDictionary objectForKey:currentDroplet.name];
    
    NSLog(@"Establish connection");
    
    // If iTerm option enabled
    if ([[userdefaults valueForKey:@"iTerm"] boolValue]) {
        
        if (!iTerm) {
            iTerm = [SBApplication applicationWithBundleIdentifier:@"com.googlecode.iterm2"];
        };
        
        [iTerm activate];
        if ([iTerm isRunning]) {

            iTermTerminal *terminal = [iTerm currentTerminal];
            
            iTermSession *session = [terminal currentSession];
            
            session.name = currentDroplet.name;

            
            
            [session writeContentsOfFile:nil text:[NSString stringWithFormat:@"ssh %@@%@ -p %@", dropletSSHUsername,  currentDroplet.ip,dropletSSHPort]];
            
        }
    } else {
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ssh://%@@%@:%@", dropletSSHUsername,  currentDroplet.ip,dropletSSHPort]]];

    }
    
}


    
    


- (void)deleteDroplet:(id)sender {
    
    Droplet *currentDroplet = (Droplet*)sender;
    
    [dropletManager deleteDroplet:currentDroplet];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        Droplet *currentDroplet = (__bridge_transfer Droplet*)contextInfo;

        if (alert == rebootAlert) {
            [self rebootDroplet:currentDroplet];
        } else if (alert == shutdownAlert) {
            [self shutdownDroplet:currentDroplet];
        } else if (alert == deleteConfirmAlert) {
            [self deleteDroplet:currentDroplet];
        }
        DLog(@"Action confirmed");
    }
    else if (returnCode == NSCancelButton)
    {
        DLog(@"Action canceled");
    }
}

#pragma mark -
#pragma mark Refreshing timer callback

- (void) refreshingTimerTick:(NSTimer*)timer {
    fade += delta;
    if(fade <= 0.0) {
        fade = 0.0;
        delta = -delta;
    } else if(fade >= 1.0) {
        fade = 1.0;
        delta = -delta;
    }
    
    NSImage *img1 = [NSImage imageNamed:@"dropletStatusIconHighlightedTemplate"];
    NSImage *img2 = [NSImage imageNamed:@"dropletStatusIconTemplate"];
    NSSize size = img1.size;
    NSImage *img = [[NSImage alloc] initWithSize: size];
    NSRect r = NSMakeRect(0, 0, size.width, size.height);
    [img lockFocus];
    [img1 drawInRect: r fromRect: r operation: NSCompositeCopy fraction: 1.0];
    [img2 drawInRect: r fromRect: r operation: NSCompositeSourceOver fraction: fade];
    [img unlockFocus];
    [img setTemplate:YES];

    _statusItem.image = img;
}


#pragma mark -
#pragma mark Notification methods

- (void) receivedNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"dropletsLoaded"]) {

        [self createMenuItems];
        refreshMI.title = @"Refresh";
        refreshMI.action = @selector(refresh:);
        
        
    } else if ([[notification name] isEqualToString:@"dropletsFailed"]) {
    
        refreshMI.title = NSLocalizedString(@"Refresh", @"Refresh");
        refreshMI.action = @selector(refresh:);
    
        [self setStatusImage: @"dropletStatusIconFailedTemplate"];
        
    }
}

@end
