***REMOVED***
***REMOVED***  PreferencesWindowController.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "PreferencesWindowController.h"
#import "KeychainAccess.h"
#import "LaunchAtLoginController.h"
#import "DropletManager.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController {
    NSMutableData *responseData;
    
    LaunchAtLoginController *launchController;
    
    DropletManager *dropletManager;
    NSUserDefaults *userdefaults;
    NSMutableDictionary *sshUserDictionary;
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
    launchController = [[LaunchAtLoginController alloc] init];
    _launchAtLoginCB.state = [launchController launchAtLogin];
    
    dropletManager = [DropletManager sharedManager];
    userdefaults = [NSUserDefaults standardUserDefaults];
    
    
    ***REMOVED***    If dictionary exists, load it from userDefaults;
    if ([userdefaults objectForKey:@"sshUserDictionary"] == nil) {
        sshUserDictionary = [[NSMutableDictionary alloc] init];
    } else {
        sshUserDictionary = [[userdefaults objectForKey:@"sshUserDictionary"] mutableCopy];
    }
    
    
    
    
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


- (IBAction)checkLaunchAtLogin:(id)sender {

        
        [launchController setLaunchAtLogin:[sender state]];


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

        DLog(@"JSON %@", json);
        if ([[json objectForKey:@"status"] isEqualToString:@"OK"]) {
            [_statusLB setStringValue:NSLocalizedString(@"Successful! Please refresh", @"Successful! Please refresh")];
        } else {
            [_statusLB setStringValue:NSLocalizedString(@"Incorrect client-ID and/or API-Key",@"Incorrect client-ID and/or API-Key")];
        }
    } else {
        [self showAlert: error];
    }
    
}

#pragma mark -
#pragma mark NSTableview delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return dropletManager.droplets.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    ***REMOVED*** Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    

    Droplet *currentDroplet = [dropletManager.droplets objectAtIndex:row];
    

    if( [tableColumn.identifier isEqualToString:@"dropletColumn"] )
    {
        
        [cellView.textField setStringValue:currentDroplet.name];
        
        
    } else if ([tableColumn.identifier isEqualToString:@"usernameColumn"]) {
        
        if ([sshUserDictionary objectForKey:currentDroplet.name] == nil) {
            [sshUserDictionary setObject:@"root" forKey:currentDroplet.name];
            
        }
        
        NSString *currentDropletSSHUser = [sshUserDictionary objectForKey:currentDroplet.name];
        
        [cellView.textField setStringValue: currentDropletSSHUser];
        [cellView.textField setEditable:YES];
        cellView.textField.delegate = self;

    }
    
    [userdefaults setObject:sshUserDictionary forKey:@"sshUserDictionary"];
    [userdefaults synchronize];
    
    return cellView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"usernameColumn"]) {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark NSTextfield delegate methods

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSDictionary *userInfo = [obj userInfo];
    NSTextView *aView = [userInfo valueForKey:@"NSFieldEditor"];
    DLog(@"controlTextDidEndEditing %@", [aView string] );
    
    Droplet *currentDroplet = [dropletManager.droplets objectAtIndex:sshUsersTableview.selectedRow];
    
    [sshUserDictionary setObject:[aView string] forKey:currentDroplet.name];
    
    [userdefaults setObject:sshUserDictionary forKey:@"sshUserDictionary"];
    [userdefaults synchronize];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSTextView *aView = [userInfo valueForKey:@"NSFieldEditor"];
    DLog(@"controlTextDidChange >>%@<<", [aView string] );
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    DLog(@"control: textShouldEndEditing >%@<", [fieldEditor string] );
    return YES;
}

@end
