***REMOVED***
***REMOVED***  PreferencesWindowController.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "PreferencesWindowController.h"
#import "KeychainAccess.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController {
    NSMutableData *responseData;
}

#pragma mark -
#pragma mark Initialization code

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

    NSString *clientId;
    NSString *apiKey;
    
    if([KeychainAccess getClientId: &clientId andAPIKey: &apiKey error: nil]) {
        [_ClientIDTF setStringValue: clientId];
        [_APIKeyTF setStringValue: apiKey];
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)savePreferences:(id)sender {
    NSError *error = nil;
    
    [_ClientIDTF setStringValue:[_ClientIDTF.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
    [_APIKeyTF setStringValue:[_APIKeyTF.stringValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
    
    if([KeychainAccess storeClientId: _ClientIDTF.stringValue andAPIKey: _APIKeyTF.stringValue error: &error]) {
        [_statusLB setStringValue: NSLocalizedString(@"Verifying...", @"Verifying...")];
        [self requestDroplets];
    } else {
        [self showAlert: error];
    }
    
}

#pragma mark -
#pragma mark Utility methods

- (void) showAlert:(NSError*)error {
    NSAlert *alert = [NSAlert alertWithError: error];
    [alert runModal];
}

- (void) requestDroplets {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https:***REMOVED***api.digitalocean.com/droplets/?client_id=%@&api_key=%@", _ClientIDTF.stringValue, _APIKeyTF.stringValue]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(connection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        [_statusLB setStringValue: NSLocalizedString(@"Connection failed", @"Connection failed")];
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
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSUTF8StringEncoding
                          error:&error];
    
    if(json)
    {

***REMOVED***
        NSLog(@"JSON %@", json);
***REMOVED***
        if ([[json objectForKey:@"status"] isEqualToString:@"OK"]) {
            [_statusLB setStringValue:@"Successful! Please refresh"];
        } else {
            [_statusLB setStringValue:@"Incorrect client-ID and/or API-Key"];
        }
    } else {
        [self showAlert: error];
    }
    
}


@end
