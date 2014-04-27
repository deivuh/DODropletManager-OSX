//
//  Droplet.h
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

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
@property BOOL backupActive;
@property BOOL active;
@property BOOL locked;

- (id) initWithDictionary:(NSDictionary*) dictionary andRegions:(NSDictionary*) regions;

@end
