***REMOVED***
***REMOVED***  DropletManager.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by David Hsieh on 5/4/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

#import <Foundation/Foundation.h>
#import "Droplet.h"

@interface DropletManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {


    
}


@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *APIKey;
@property (nonatomic, strong) NSMutableArray *droplets;

+ (id)sharedManager;


- (void)refreshDroplets;
- (void)rebootDroplet:(Droplet*)droplet;
- (void)shutdownDroplet:(Droplet*)droplet;
- (void)turnOnDroplet:(Droplet*)droplet;


@end