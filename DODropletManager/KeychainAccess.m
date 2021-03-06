//
//  KeychainAccess.m
//  DODropletManager
//
//  Created by Daniel Parnell on 29/04/2014.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "KeychainAccess.h"
#import <Security/SecKeychain.h>

static const char *digital_ocean = "Digital Ocean";
static const char *account = "Account";


static NSString *serviceName = @"digital_ocean";

@implementation KeychainAccess



+ (BOOL) storeAccesToken:(NSString*)accessToken andRefreshToken:(NSString*)refreshToken error:(NSError**)error {
    // Set password
    SecKeychainRef keychain = NULL; // User's default keychain
    
    
    // Delete keychain item if already exists
    [self removeAccessToken:accessToken andRefreshToken:refreshToken error:(NSError**)error];
    
    const char *passwordData = [[NSString stringWithFormat: @"%@:%@", accessToken, refreshToken] UTF8String];
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

+ (BOOL) getAccessToken:(NSString**)accessToken andRefreshToken:(NSString**)refreshToken error:(NSError**)error {
    SecKeychainRef keychain = NULL; // User's default keychain
    // Get password
    char *password = NULL;
    UInt32 passwordLen = 0;
    
    OSStatus status = SecKeychainFindGenericPassword(keychain,
                                                     (UInt32)strlen(digital_ocean), digital_ocean,
                                                     (UInt32)strlen(account), account,
                                                     &passwordLen, (void**)&password,
                                                     NULL);
    
    if (status == noErr) {
        // Cool! Use pwd
        NSString *tmp = [NSString stringWithUTF8String: password];
        NSArray *parts = [tmp componentsSeparatedByString: @":"];
        
        *accessToken = [parts objectAtIndex: 0];
        *refreshToken = [parts objectAtIndex: 1];
        SecKeychainItemFreeContent(NULL, (void*)password);
        
        return YES;
    }
    
    if(error) {
        *error = [NSError errorWithDomain: NSLocalizedString(@"Keychain", @"Keychain") code: status userInfo: nil];
    }
    
    return NO;
}



+ (BOOL) removeAccessToken:(NSString*)accessToken andRefreshToken:(NSString*)refreshToken error:(NSError**)error {
    
    
    SecKeychainRef keychain = NULL; // User's default keychain
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
        if (error) {
            *error = [NSError errorWithDomain: NSLocalizedString(@"Keychain", @"Keychain") code: status userInfo: nil];
        }
    }
    
    
    
    return NO;
}

@end