***REMOVED***
***REMOVED***  AppDelegate.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "AppDelegate.h"
#import "Droplet.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    ***REMOVED***If keys load successfully, do stuff, if not, no need
***REMOVED***    if ([self loadKeys]) {
    
    [self loadKeys];
    [self requestRegions];
        
***REMOVED***    }
    

    

    
    

}

- (BOOL)loadKeys {
    
    userDefaults = [NSUserDefaults standardUserDefaults];

    


    
    ***REMOVED*** If no key values are found, no need to set them
    if ([userDefaults objectForKey:@"clientID"] == nil ||
        [userDefaults objectForKey:@"APIKey"] == nil) {
        
        return NO;
    }
    
    clientID = [userDefaults objectForKey:@"clientID"];
    APIKey = [userDefaults objectForKey:@"APIKey"];
    
    NSLog(@"Loaded: %@, %@", clientID, APIKey);
    
    return YES;

}


- (void) requestRegions {


    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/regions/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    regionsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(regionsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"connection failed");
    }
    
    
    
    
}

- (void) requestImages {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/images/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    imagesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(imagesConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"connection failed");
    }
    
}




- (void) requestDroplets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/?client_id=%@&api_key=%@", clientID, APIKey]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    dropletsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(dropletsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        NSLog(@"connection failed");
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
    
    NSLog(@"connection error");
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
                
                NSLog(@"Droplet: %@, image: %@", droplet.name, droplet.imageID);
                
            }
            


            [self createMenuItems];
            
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
                
                NSLog(@"Image: %@:%@", imageID, distro);
                
                
                [images setObject:distro forKey:imageID];
            }
            
            
            [self requestDroplets];
            
        
        }
        
    }
    

    
    
}

- (void) createMenuItems {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"DropletStatusIcon"];
    _statusItem.alternateImage = [NSImage imageNamed:@"DropletStatusIconHighlighted"];
    _statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] init];

    
    for (Droplet *droplet in dropletsArray) {
        [menu addItemWithTitle:droplet.name  action:nil keyEquivalent:@""];

        NSMenu *submenu = [[NSMenu alloc] init];
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Status: %@", droplet.status]
                           action:nil
                    keyEquivalent:@""];

        [submenu addItemWithTitle:[NSString stringWithFormat:@"IP: %@", droplet.ip]
                           action:@selector(copyIPAddress:)
                    keyEquivalent:@""];
        
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Region: %@", droplet.region]
                           action:nil
                    keyEquivalent:@""];
        
        [submenu addItemWithTitle:[NSString stringWithFormat:@"Distro: %@", droplet.distro]
                           action:nil
                    keyEquivalent:@""];
        
        [menu setSubmenu:submenu forItem:menu.itemArray.firstObject];
        
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:@"Refresh" action:nil keyEquivalent:@""];
    [menu addItemWithTitle:@"Preferences" action:@selector(showPreferencesWindow:) keyEquivalent:@""];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit DO Indicator" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
}

- (void)copyIPAddress:(id)sender {
    NSString *ipAddress = ((NSMenuItem*)sender).title;
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:ipAddress forType:NSStringPboardType];
}


- (void)showPreferencesWindow:(id)sender {
    _preferencesWC = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    [_preferencesWC showWindow:self];
    
}

@end
