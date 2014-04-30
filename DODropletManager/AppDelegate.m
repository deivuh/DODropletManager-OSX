***REMOVED***
***REMOVED***  AppDelegate.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "AppDelegate.h"
#import "Droplet.h"
#import "KeychainAccess.h"

@implementation AppDelegate {
    NSMutableData *responseData;
    NSMutableArray *dropletsArray;
    
    NSURLConnection *dropletsConnection, *regionsConnection, *imagesConnection;
    
    NSURLConnection *rebootDropletConnection, *shutdownDropletConnection, *turnOnDropletConnection;
    
    NSString *clientID, *APIKey;
    
    NSMutableDictionary *regions;
    NSMutableDictionary *images;
    
    NSUserDefaults *userDefaults;
    
    
    NSMenuItem *refreshMI;
    NSAlert *rebootAlert, *shutdownAlert;
    
    NSTimer *refreshingTimer;
    float fade, delta;
    
    BOOL firstRun;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self createMenuItems];
    
    if([self loadKeys]) {
        [self refresh: self];
    } else {
        [self showPreferencesWindow: self];
    }

}

- (BOOL)loadKeys {
    NSString *client;
    NSString *key;
    
    if([KeychainAccess getClientId: &client andAPIKey: &key error: nil]) {
        clientID = client;
        APIKey = key;
        
        return YES;
    }
    
    return NO;

}

#pragma mark -
#pragma mark Communication methods

- (void) requestRegions {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/regions/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    regionsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(regionsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }

}

- (void) requestImages {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/images/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    imagesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(imagesConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}

- (void) requestDroplets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    dropletsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(dropletsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
    
}

- (void) requestRebootForDroplet:(Droplet*)droplet {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/%@/reboot/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    rebootDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(rebootDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}

- (void) requestShutdownForDroplet:(Droplet*)droplet {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/%@/shutdown/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    shutdownDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(shutdownDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
    
}

- (void) requestTurnOnForDroplet:(Droplet*)droplet {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/%@/power_on/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    turnOnDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    DLog(@"Request turnOn %@", urlRequest.URL);
    
    if(turnOnDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    responseData = nil;
    
    DLog(@"connection error");
    refreshMI.title = NSLocalizedString(@"Refresh", @"Refresh");
    refreshMI.action = @selector(refresh:);
    
    [self setStatusImage: @"DropletStatusIconFailed"];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSUTF8StringEncoding
                          error:&error];
    
    if(json != nil)
    {
        if (connection == dropletsConnection) {
            NSArray *tempDropletsArray = [json objectForKey:@"droplets"];
            dropletsArray = [[NSMutableArray alloc] init];

            for (NSDictionary *dropletDictionary in tempDropletsArray) {
                Droplet *droplet = [[Droplet alloc] initWithDictionary:dropletDictionary regions:regions andImages:images];
                [dropletsArray addObject:droplet];
            }

            [self createMenuItems];
            refreshMI.title = @"Refresh";
            refreshMI.action = @selector(refresh:);
        } else  if (connection == regionsConnection) {
            NSArray *tempRegionsArray = [json objectForKey:@"regions"];
            regions = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary *region in tempRegionsArray) {
                NSString *regionID = [region objectForKey:@"id"];
                NSString *regionName = [region objectForKey:@"name"];
                
                [regions setObject:regionName forKey:regionID];
            }
            
            [self requestImages];
        } else  if (connection == imagesConnection) {
            NSArray *tempImagesArray = [json objectForKey:@"images"];
            images = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary *image in tempImagesArray) {
                NSString *imageID = [image objectForKey:@"id"];
                NSString *distro = [image objectForKey:@"name"];
                
                [images setObject:distro forKey:imageID];
            }
            
            [self requestDroplets];
        } else  if (connection == rebootDropletConnection) {
            DLog(@"Result status %@", [json objectForKey:@"status"]);
            [self refresh:self];
        } else  if (connection == shutdownDropletConnection) {
            DLog(@"Result status %@", json);
            [self refresh:self];
        } else  if (connection == turnOnDropletConnection) {
            DLog(@"Result status %@", json);
            [self refresh:self];
        }
    }
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
        _statusItem.alternateImage = [NSImage imageNamed:@"DropletStatusIconHighlighted"];
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
    
    [self setStatusImage: @"DropletStatusIcon"];
    
    int dropletMIIndex = 0;
    
    for (Droplet *droplet in dropletsArray) {
        [menu insertItemWithTitle: droplet.name action: nil keyEquivalent: @"" atIndex: dropletMIIndex];

        NSMenu *submenu = [[NSMenu alloc] init];
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Status: %@", droplet.status]
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
        
        [viewOnWebMI setImage:[NSImage imageNamed:@"info-icon"]];
        [viewOnWebMI setRepresentedObject:droplet];
        
        [submenu addItem:viewOnWebMI];
        
        NSMenuItem *connectToDroplet = [[NSMenuItem alloc] initWithTitle:@"Connect to Droplet" action:@selector(establishSSHConnectionToDroplet:) keyEquivalent:@""];
        
        [connectToDroplet setImage:[NSImage imageNamed:@"ssh-icon"]];
        [connectToDroplet setRepresentedObject:droplet];
        
        [submenu addItem:connectToDroplet];
        
        NSMenuItem *rebootMI = [[NSMenuItem alloc] initWithTitle:@"Reboot" action:@selector(confirmReboot:) keyEquivalent:@""];
        
        [rebootMI setImage:[NSImage imageNamed:@"reboot-icon"]];
        [rebootMI setRepresentedObject:droplet];
        
        [submenu addItem:rebootMI];
        
        if (droplet.active) {
            NSMenuItem *shutdownMI = [[NSMenuItem alloc] initWithTitle:@"Shutdown" action:@selector(confirmShutdown:) keyEquivalent:@""];
            
            [shutdownMI setImage:[NSImage imageNamed:@"power-icon"]];
            [shutdownMI setRepresentedObject:droplet];
            
            [submenu addItem:shutdownMI];
            
        } else {

            NSMenuItem *turnOnMI = [[NSMenuItem alloc] initWithTitle:@"Power On" action:@selector(turnOnDroplet:) keyEquivalent:@""];
            [turnOnMI setImage:[NSImage imageNamed:@"power-icon"]];
            [turnOnMI setRepresentedObject:droplet];
        
            [submenu addItem:turnOnMI];
        }
        
        [menu setSubmenu:submenu forItem:[menu.itemArray objectAtIndex:dropletMIIndex]];
        dropletMIIndex ++;
        
    }
    
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


- (void)showPreferencesWindow:(id)sender {
    
    ***REMOVED***Show preferences window
    _preferencesWC = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    [_preferencesWC showWindow:self];
    
    ***REMOVED***Focus on window
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
    [self requestRegions];
}

- (void)confirmReboot:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    rebootAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Reboot '%@'", currentDroplet.name]
                                     defaultButton:@"Ok"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Do you wish to proceed?"];
    [rebootAlert beginSheetModalForWindow:[self window]
                      modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:(__bridge_retained void *)(currentDroplet)];
    
    
}


- (void)confirmShutdown:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    

    
    shutdownAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Shutdown '%@'", currentDroplet.name]
                                  defaultButton:@"Ok"
                                alternateButton:@"Cancel"
                                    otherButton:nil
                      informativeTextWithFormat:@"Do you wish to proceed?"];
    [shutdownAlert beginSheetModalForWindow:[self window]
                              modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                contextInfo:(__bridge_retained void *)(currentDroplet)];
    

}

- (void)rebootDroplet:(id)sender {
    
    Droplet *currentDroplet = (Droplet*)sender;
    
    [self requestRebootForDroplet:currentDroplet];
    
}

- (void)shutdownDroplet:(id)sender {
    
    Droplet *currentDroplet = (Droplet*)sender;
    
    [self requestShutdownForDroplet:currentDroplet];
}

- (void)turnOnDroplet:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    [self requestTurnOnForDroplet:currentDroplet];
}

- (void)viewDropletOnBrowser:(id)sender {
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***cloud.digitalocean.com/droplets/%@", currentDroplet.dropletID]]];
    
}

- (void)establishSSHConnectionToDroplet:(id)sender {
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"ssh:***REMOVED***root@%@", currentDroplet.ip]]];
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
        }
        DLog(@"(returnCode == NSOKButton)");
    }
    else if (returnCode == NSCancelButton)
    {
        DLog(@"(returnCode == NSCancelButton)");
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
    
    NSImage *img1 = [NSImage imageNamed:@"DropletStatusIconHighlighted"];
    NSImage *img2 = [NSImage imageNamed:@"DropletStatusIcon"];
    NSSize size = img1.size;
    NSImage *img = [[NSImage alloc] initWithSize: size];
    NSRect r = NSMakeRect(0, 0, size.width, size.height);
    [img lockFocus];
    [img1 drawInRect: r fromRect: r operation: NSCompositeCopy fraction: 1.0];
    [img2 drawInRect: r fromRect: r operation: NSCompositeSourceOver fraction: fade];
    [img unlockFocus];
    
    _statusItem.image = img;
}

@end
