//
//  KeychainAccess.h
//  DODropletManager
//
//  Created by Daniel Parnell on 29/04/2014.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainAccess : NSObject


+ (BOOL) storeAccessToken:(NSString*)token error:(NSError**)error;
+ (BOOL) getAccessToken:(NSString**)token error:(NSError**)error;

+ (BOOL) storeRefreshToken:(NSString*)token error:(NSError**)error;
+ (BOOL) getRefreshToken:(NSString**)token error:(NSError**)error;

@end
