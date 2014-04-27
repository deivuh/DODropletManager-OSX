***REMOVED***
***REMOVED***  Droplet.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 4/27/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import <Foundation/Foundation.h>

@interface Droplet : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *dropletID;
@property (nonatomic, strong) NSString *imageID;
@property (nonatomic, strong) NSString *sizeID;
@property (nonatomic, strong) NSString *regionID;
@property (nonatomic, strong) NSString *privateIP;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *status;

@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *distro;
@property BOOL backupActive;
@property BOOL active;
@property BOOL locked;

- (id) initWithDictionary:(NSDictionary*) dictionary regions:(NSDictionary*) regions andImages:(NSDictionary*)images;

@end
