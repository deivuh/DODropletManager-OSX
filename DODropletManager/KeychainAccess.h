***REMOVED***
***REMOVED***  KeychainAccess.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by Daniel Parnell on 29/04/2014.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import <Foundation/Foundation.h>

@interface KeychainAccess : NSObject

+ (BOOL) storeClientId:(NSString*)clientId andAPIKey:(NSString*)apiKey error:(NSError**)error;
+ (BOOL) getClientId:(NSString**)clientId andAPIKey:(NSString**)apiKey error:(NSError**)error;

@end
