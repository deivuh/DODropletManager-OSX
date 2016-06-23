//
//  PreferencesWindowController.m
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "KeychainAccess.h"
#import "LaunchAtLoginController.h"
#import <ApplicationServices/ApplicationServices.h>


@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController {
    NSMutableData *responseData;
    
    LaunchAtLoginController *launchController;
    
    DropletManager *dropletManager;
    NSUserDefaults *userdefaults;
    NSMutableDictionary *sshUserDictionary;
    NSMutableDictionary *sshPortDictionary;
    
    NSString *authorizationCode;
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
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];


    launchController = [[LaunchAtLoginController alloc] init];
    _launchAtLoginCB.state = [launchController launchAtLogin];
    
    dropletManager = [DropletManager sharedManager];
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
    
    NSString *pVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (pVersion != nil && ![pVersion isEqualToString:@""]) {
        [self.versionLabel setStringValue: [NSString stringWithFormat: @"Version: %@", pVersion]];
    } else {
        [self.versionLabel setStringValue:@""];
    }
    
//    if([KeychainAccess getClientId: &clientId andAPIKey: &apiKey error: nil]) {
//        [_ClientIDTF setStringValue: clientId];
//        [_APIKeyTF setStringValue: apiKey];
//    }
    
    

    
    [self registerAppURL];


    [_iTermCB setEnabled:[self checkiTerm]];
    
    if ([[userdefaults valueForKey:@"iTerm"] boolValue]) {
        [_iTermCB setState:NSOnState];
    } else
        [_iTermCB setState:NSOffState];

    if ([[userdefaults valueForKey:@"publicIPs"] boolValue]) {
        [_publicIPsCB setState:NSOnState];
    } else
        [_publicIPsCB setState:NSOffState];

    dropletManager.delegate = self;

    if ([dropletManager isConnectionSuccessful]) {
        [_statusLB setStringValue:@"Connected"];
        [_accountNameLB setStringValue:dropletManager.accountName];
    } else {
        [_statusLB setStringValue:@"Something is wrong"];
        [_accountNameLB setStringValue:@""];
    }
    
}



#pragma mark -
#pragma mark Actions


- (IBAction)linkAccount:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloud.digitalocean.com/v1/oauth/authorize?client_id=%@&redirect_uri=dodm%%3A%%2F%%2Fauthorization&response_type=code&scope=read%%20write", clientID]]];
    
    [_statusLB setStringValue:@"Requesting authorization..."];
}


- (IBAction)checkLaunchAtLogin:(id)sender {

        
        [launchController setLaunchAtLogin:[sender state]];


}

- (IBAction)publicIPsChecked:(id)sender {
    [userdefaults setValue:[NSNumber numberWithBool:_publicIPsCB.state] forKey:@"publicIPs"];
    [userdefaults synchronize];

}

- (IBAction)iTermChecked:(id)sender {
    [userdefaults setValue:[NSNumber numberWithBool:_iTermCB.state] forKey:@"iTerm"];
    [userdefaults synchronize];
}

#pragma mark -
#pragma mark Utility methods

- (void) showAlert:(NSError*)error {
    NSAlert *alert = [NSAlert alertWithError: error];
    [alert runModal];
}

#pragma mark -
#pragma mark Connection methods



- (void) requestTokenWithAuthorizationCode:(NSString*)code {
    DLog(@"Authorization code %@", code);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://cloud.digitalocean.com/v1/oauth/token?client_id=%@&client_secret=%@&grant_type=authorization_code&code=%@&redirect_uri=%@", clientID, clientSecret, code, @"dodm://authorization"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    [_statusLB setStringValue:@"Requesting access token..."];
    
    if(connection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        [_statusLB setStringValue: NSLocalizedString(@"Connection failed", @"Connection failed")];
    }
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

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

        DLog(@"Token request response:  %@", json);
        if ([json objectForKey:@"access_token"]) {

            dropletManager.accessToken = [json objectForKey:@"access_token"];
            dropletManager.refreshToken = [json objectForKey:@"refresh_token"];
            
            DLog(@"Access token %@", dropletManager.accessToken);
            
            if ([json objectForKey:@"info"]) {
                [_accountNameLB setStringValue:[[json objectForKey:@"info"] objectForKey:@"name"]];
                [_linkAccountBT setTitle:@"Unlink"];
                
                dropletManager.accountName =[_accountNameLB stringValue];
                
                [userdefaults setObject:dropletManager.accountName forKey:@"accountName"];
                [userdefaults synchronize];
            }
            
            
            [self saveToken];
            

            
        } else {
            DLog(@"Token request error");
        }
    } else {
        [self showAlert: error];
    }
    
}

#pragma mark -
#pragma mark URL Scheme methods

- (void)registerAppURL {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue]; // Now you can parse the URL and perform whatever action is needed
    
    DLog(@"Captured URL: %@", url);
    
    url = [[url componentsSeparatedByString:@"?"] objectAtIndex:1];
    
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [url componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    
    if ([queryStringDictionary objectForKey:@"code"] == nil) {

            if ([queryStringDictionary objectForKey:@"error"]) {
                if ([[queryStringDictionary objectForKey:@"error"] isEqualToString:@"access_denied"]) {
                    [_statusLB setStringValue:@"Acces denied. Please grant DropletManager authorization to your account"];
                }
            }
        
        
    } else {
        authorizationCode = [queryStringDictionary objectForKey:@"code"];
        [self requestTokenWithAuthorizationCode:authorizationCode];
    }
    
}

#pragma mark -
#pragma mark NSTableview delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return dropletManager.droplets.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
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
        

    } else if ([tableColumn.identifier isEqualToString:@"portColumn"]) {
        
        if ([sshPortDictionary objectForKey:currentDroplet.name] == nil) {
            [sshPortDictionary setObject:@"22" forKey:currentDroplet.name];
            
        }
        
        NSString *currentDropletSSHPort = [sshPortDictionary objectForKey:currentDroplet.name];
        
        [cellView.textField setStringValue: currentDropletSSHPort];
        [cellView.textField setEditable:YES];
        cellView.textField.delegate = self;
        
        
    }
    
//    cellView.objectValue = cellView.textField;
    
    [userdefaults setObject:sshUserDictionary forKey:@"sshUserDictionary"];
    [userdefaults setObject:sshPortDictionary forKey:@"sshPortDictionary"];
    [userdefaults synchronize];
    

    
    return cellView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"usernameColumn"]) {
        return YES;
    }
    
    if ([tableColumn.identifier isEqualToString:@"portColumn"]) {
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
    NSString *inputString = [aView string];
    DLog(@"controlTextDidEndEditing %@", inputString );
    
    NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Invalid port number" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Should be a number within range 1-65535" ];
    
    NSTextField *currentTextField = (NSTextField*)[obj object];
    
    Droplet *currentDroplet = [dropletManager.droplets objectAtIndex:sshUsersTableview.selectedRow];
    
    
    NSInteger selected = [sshUsersTableview selectedRow];
    
    NSTextField *selectedUserTF = [[sshUsersTableview viewAtColumn:1 row:selected makeIfNecessary:YES] textField];
    
    NSTextField *selectedPortTF = [[sshUsersTableview viewAtColumn:2 row:selected makeIfNecessary:YES] textField];

    
    if (currentTextField == selectedUserTF) {
        DLog(@"UserTF end editing");
        [sshUserDictionary setObject:inputString forKey:currentDroplet.name];
        
        [userdefaults setObject:sshUserDictionary forKey:@"sshUserDictionary"];
    } else if (currentTextField == selectedPortTF) {
        DLog(@"PortTF end editing");
        
        //Check if valid port
        if([inputString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
            
            if ([inputString integerValue] > 65535 || [inputString integerValue] < 1) {
                
                [errorAlert runModal];
                
                return;
            }
            
            
            
        } else {
            [errorAlert runModal];
            return;
        }
        
        
        [sshPortDictionary setObject:inputString forKey:currentDroplet.name];
        
        [userdefaults setObject:sshPortDictionary forKey:@"sshPortDictionary"];
    }
    

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

#pragma mark -
#pragma mark Other methods

- (BOOL) checkiTerm {
    
    BOOL isPresent = NO;
    
    CFURLRef appURL = NULL;
    OSStatus result = LSFindApplicationForInfo (
                                                kLSUnknownCreator,         //creator codes are dead, so we don't care about it
                                                CFSTR("com.googlecode.iterm2"), //you can use the bundle ID here
                                                NULL,                      //or the name of the app here (CFSTR("Safari.app"))
                                                NULL,                      //this is used if you want an FSRef rather than a CFURLRef
                                                &appURL
                                                );
    switch(result)
    {
        case noErr:
            NSLog(@"the app's URL is: %@",appURL);
            isPresent = YES;
            break;
        case kLSApplicationNotFoundErr:
            NSLog(@"app not found");

            break;
        default:
            NSLog(@"an error occurred: %d",result);

            break;
    }
    
    //the CFURLRef returned from the function is retained as per the docs so we must release it
    if(appURL)
        CFRelease(appURL);

    
    return isPresent;
}

- (void) saveToken {
    
    NSError *error = nil;
    
    DLog(@"Saving token %@", dropletManager.accessToken);
    
    if([KeychainAccess storeAccesToken:dropletManager.accessToken andRefreshToken:dropletManager.refreshToken error:nil]) {
        
        [dropletManager testConnection];
        [_statusLB setStringValue:@"Testing connection..."];

    } else {
        [self showAlert: error];
    }
}

- (void)connectionTestFinishedWithResult:(NSDictionary *)result {
    

    
    if ([result objectForKey:@"regions"]) {
        [_statusLB setStringValue:@"Online"];
    }

    
}

@end
