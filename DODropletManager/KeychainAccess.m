***REMOVED***
***REMOVED***  KeychainAccess.m
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by Daniel Parnell on 29/04/2014.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import "KeychainAccess.h"
#import <Security/SecKeychain.h>

static const char *digital_ocean = "Digital Ocean";
static const char *account = "Account";

static NSString *serviceName = @"digital_ocean";

@implementation KeychainAccess

+ (BOOL) storeClientId:(NSString*)clientId andAPIKey:(NSString*)apiKey error:(NSError**)error {
    ***REMOVED*** Set password
    SecKeychainRef keychain = NULL; ***REMOVED*** User's default keychain
    
    
    ***REMOVED*** Delete keychain item if already exists
    [self removeClientId:clientId andAPIKey:apiKey error:nil];
    
    const char *passwordData = [[NSString stringWithFormat: @"%@:%@", clientId, apiKey] UTF8String];
    OSStatus status = SecKeychainAddGenericPassword(keychain,
                                                    (UInt32)strlen(digital_ocean), digital_ocean,
                                                    (UInt32)strlen(account), account,
                                                    (UInt32)strlen(passwordData), passwordData,
                                                    NULL);
    
    

    
    if (status == noErr) {
        return YES;
    }
    
    if(error) {
        *error = [NSError errorWithDomain: NSLocalizedString(@"Keychain", @"Keychain") code: status userInfo: nil];
    }
    
    return NO;
}

+ (BOOL) getClientId:(NSString**)clientId andAPIKey:(NSString**)apiKey error:(NSError**)error {
    SecKeychainRef keychain = NULL; ***REMOVED*** User's default keychain
    ***REMOVED*** Get password
    char *password = NULL;
    UInt32 passwordLen = 0;
    
    OSStatus status = SecKeychainFindGenericPassword(keychain,
                                            (UInt32)strlen(digital_ocean), digital_ocean,
                                            (UInt32)strlen(account), account,
                                            &passwordLen, (void**)&password,
                                            NULL);
    
    if (status == noErr) {
        ***REMOVED*** Cool! Use pwd
        NSString *tmp = [NSString stringWithUTF8String: password];
        NSArray *parts = [tmp componentsSeparatedByString: @":"];
        
        *clientId = [parts objectAtIndex: 0];
        *apiKey = [parts objectAtIndex: 1];
        SecKeychainItemFreeContent(NULL, (void*)password);
        
        return YES;
    }
    
    if(error) {
        *error = [NSError errorWithDomain: NSLocalizedString(@"Keychain", @"Keychain") code: status userInfo: nil];
    }
    
    return NO;
}



+ (BOOL) removeClientId:(NSString*)clientId andAPIKey:(NSString*)apiKey error:(NSError**)error {
    
    
    SecKeychainRef keychain = NULL; ***REMOVED*** User's default keychain
    SecKeychainItemRef keychainItem;
    
    OSStatus status = SecKeychainFindGenericPassword(keychain,
                                                     (UInt32)strlen(digital_ocean), digital_ocean,
                                                     (UInt32)strlen(account), account,
                                                     NULL, NULL,
                                                     &keychainItem);
    
    
    if (status == noErr) {
        SecKeychainItemDelete(keychainItem);
        CFRelease(keychainItem);
    } else {
        *error = [NSError errorWithDomain: NSLocalizedString(@"Keychain", @"Keychain") code: status userInfo: nil];
    }
    
    
    
    return NO;
}

@end
