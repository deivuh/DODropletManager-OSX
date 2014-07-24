//
//  KeychainAccess.h
//  DODropletManager
//
//  Created by Daniel Parnell on 29/04/2014.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainAccess : NSObject


+ (BOOL) storeToken:(NSString*)token error:(NSError**)error;
+ (BOOL) getToken:(NSString**)token error:(NSError**)error;

@end
