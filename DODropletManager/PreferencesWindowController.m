***REMOVED***
***REMOVED***  PreferencesWindowController.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController


- (id)init {
    self=[super initWithWindowNibName:@"PreferencesWindow"];
    if(self)
    {
        

    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        ***REMOVED*** Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    

    
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    if ([userDefaults objectForKey:@"clientID"]) {
        [_ClientIDTF setStringValue:[userDefaults objectForKey:@"clientID"]];
    }
    
    if ([userDefaults objectForKey:@"APIKey"]) {
        [_APIKeyTF setStringValue:[userDefaults objectForKey:@"APIKey"]];
    }
    
    NSLog(@"ClientID %@", [userDefaults objectForKey:@"clientID"]);
}


- (IBAction)savePreferences:(id)sender {
    
    
    [_ClientIDTF setStringValue:[_ClientIDTF.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
    [_APIKeyTF setStringValue:[_APIKeyTF.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
    
    
    [userDefaults setObject:_ClientIDTF.stringValue forKey:@"clientID"];
    [userDefaults setObject:_APIKeyTF.stringValue forKey:@"APIKey"];
    
    [userDefaults synchronize];
    
    NSLog(@"saved %@", _ClientIDTF.stringValue);

    
***REMOVED***    if ([_ClientIDTF.stringValue length] != 32 || [_APIKeyTF.stringValue length] != 32) {
***REMOVED***        [_statusLB setStringValue:@"Incorrect client-ID and/or API-Key length"];
***REMOVED***    } else {
        [_statusLB setStringValue:@"Verifying..."];
        [self requestDroplets];
***REMOVED***    }
    
}


- (void) requestDroplets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/?client_id=%@&api_key=%@", _ClientIDTF.stringValue, _APIKeyTF.stringValue]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(connection) {
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
        
        NSLog(@"JSON %@", json);
        
        if ([[json objectForKey:@"status"] isEqualToString:@"OK"]) {
            [_statusLB setStringValue:@"Successful! Please refresh"];
        } else {
            [_statusLB setStringValue:@"Incorrect client-ID and/or API-Key"];
        }
    }
    
}


@end
