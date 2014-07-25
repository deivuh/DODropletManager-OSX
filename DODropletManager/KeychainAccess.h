//
//  KeychainAccess.h
//  DODropletManager
//
//  Created by Daniel Parnell on 29/04/2014.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainAccess : NSObject



+ (BOOL) storeAccesToken:(NSString*)accessToken andRefreshToken:(NSString*)refreshToken error:(NSError**)error;
+ (BOOL) getAccessToken:(NSString**)accessToken andRefreshToken:(NSString**)refreshToken error:(NSError**)error;

@end

