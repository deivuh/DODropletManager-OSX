//
//  KeychainAccess.h
//  DODropletManager
//
//  Created by Daniel Parnell on 29/04/2014.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainAccess : NSObject

+ (BOOL) storeClientId:(NSString*)clientId andAPIKey:(NSString*)apiKey error:(NSError**)error;
+ (BOOL) getClientId:(NSString**)clientId andAPIKey:(NSString**)apiKey error:(NSError**)error;

@end
