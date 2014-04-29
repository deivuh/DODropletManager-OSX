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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if([self loadKeys]) {
        [self requestRegions];
    } else {
        [self createMenuItems];
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


- (void) requestRegions {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/regions/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    regionsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(regionsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
    }
}

- (void) requestImages {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/images/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    imagesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(imagesConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
    }
}

- (void) requestDroplets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    dropletsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(dropletsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
    }
    
}

- (void) requestRebootForDroplet:(Droplet*)droplet {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/reboot/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    rebootDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(rebootDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
    }
}

- (void) requestShutdownForDroplet:(Droplet*)droplet {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/shutdown/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    shutdownDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(shutdownDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
    }
    
}

- (void) requestTurnOnForDroplet:(Droplet*)droplet {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/power_on/?client_id=%@&api_key=%@", droplet.dropletID, clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    turnOnDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
#ifdef DEBUG
    NSLog(@"Request turnOn %@", urlRequest.URL);
#endif
    
    if(turnOnDropletConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
#ifdef DEBUG
        NSLog(@"connection failed");
#endif
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
    
#ifdef DEBUG
    NSLog(@"connection error");
#endif
    refreshMI.title = @"Refresh";
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
            
            dropletsArray = [[NSMutableArray alloc] init];
            NSArray *tempDropletsArray = [json objectForKey:@"droplets"];

            for (NSDictionary *dropletDictionary in tempDropletsArray) {
                Droplet *droplet = [[Droplet alloc] initWithDictionary:dropletDictionary regions:regions andImages:images];
                [dropletsArray addObject:droplet];
                

            }
            


            [self createMenuItems];
            refreshMI.title = @"Refresh";
            refreshMI.action = @selector(refresh:);
            
        } else  if (connection == regionsConnection) {
            
            regions = [[NSMutableDictionary alloc] init];
            NSArray *tempRegionsArray = [json objectForKey:@"regions"];
            
            for (NSDictionary *region in tempRegionsArray) {
                NSString *regionID = [region objectForKey:@"id"];
                NSString *regionName = [region objectForKey:@"name"];
                
                [regions setObject:regionName forKey:regionID];
            }
            
            
            [self requestImages];
            
        } else  if (connection == imagesConnection) {
            
            images = [[NSMutableDictionary alloc] init];
            NSArray *tempImagesArray = [json objectForKey:@"images"];
            
            for (NSDictionary *image in tempImagesArray) {
                NSString *imageID = [image objectForKey:@"id"];
                NSString *distro = [image objectForKey:@"name"];
                
                
                
                
                [images setObject:distro forKey:imageID];
            }
            
            
            [self requestDroplets];
            
        
        } else  if (connection == rebootDropletConnection) {
            
#ifdef DEBUG
            NSLog(@"Result status %@", [json objectForKey:@"status"]);
#endif
            [self refresh:self];
            
        } else  if (connection == shutdownDropletConnection) {
#ifdef DEBUG
            NSLog(@"Result status %@", json);
#endif
            [self refresh:self];
            
        } else  if (connection == turnOnDropletConnection) {
#ifdef DEBUG
            NSLog(@"Result status %@", json);
#endif
            [self refresh:self];
            
        }
    }
}

- (void) createMenuItems {
    NSMenu *menu;
    BOOL add_items;
    if(_statusItem == nil) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        
        _statusItem.title = @"";
        _statusItem.image = [NSImage imageNamed:@"DropletStatusIcon"];
        _statusItem.alternateImage = [NSImage imageNamed:@"DropletStatusIconHighlighted"];
        _statusItem.highlightMode = YES;
        menu = [[NSMenu alloc] init];
        add_items = YES;
    } else {
        menu = _statusItem.menu;
        add_items = NO;
        
        while(![[menu itemAtIndex: 0] isSeparatorItem]) {
            [menu removeItemAtIndex: 0];
        }
    }
    
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
            [submenu addItemWithTitle:[NSString stringWithFormat:@"Distro: %@", droplet.distro]
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
        
        
        NSMenuItem *rebootMI = [[NSMenuItem alloc] initWithTitle:@"Reboot" action:@selector(rebootDroplet:) keyEquivalent:@""];
        
        [rebootMI setImage:[NSImage imageNamed:@"reboot-icon"]];
        [rebootMI setRepresentedObject:droplet];
        
        [submenu addItem:rebootMI];
        
        if (droplet.active) {
            NSMenuItem *shutdownMI = [[NSMenuItem alloc] initWithTitle:@"Shutdown" action:@selector(shutdownDroplet:) keyEquivalent:@""];
            
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
    
    if(add_items) {
        [menu addItem:[NSMenuItem separatorItem]];
        
        refreshMI = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(refresh:) keyEquivalent:@""];
        [menu addItem:refreshMI];
        
        [menu addItemWithTitle:@"Preferences" action:@selector(showPreferencesWindow:) keyEquivalent:@""];
        
        [menu addItem:[NSMenuItem separatorItem]];

        
        [menu addItemWithTitle:@"Quit Droplets Manager" action:@selector(terminate:) keyEquivalent:@""];
        _statusItem.menu = menu;
    }
}

- (void)copyIPAddress:(id)sender {
    
    NSString *ipAddress = ((NSMenuItem*)sender).representedObject;
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:ipAddress forType:NSStringPboardType];
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
    
    refreshMI.title = @"Refreshing...";
    refreshMI.action = nil;
    [self requestRegions];
}

- (void)rebootDroplet:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    [self requestRebootForDroplet:currentDroplet];
    
}

- (void)shutdownDroplet:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    [self requestShutdownForDroplet:currentDroplet];
}

- (void)turnOnDroplet:(id)sender {
    
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;
    
    [self requestTurnOnForDroplet:currentDroplet];
}

- (void)viewDropletOnBrowser:(id)sender {
    Droplet *currentDroplet = ((NSMenuItem*)sender).representedObject;

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloud.digitalocean.com/droplets/%@", currentDroplet.dropletID]]];
    
}




@end
