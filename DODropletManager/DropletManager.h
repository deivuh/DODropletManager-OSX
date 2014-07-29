//
//  DropletManager.h
//  DODropletManager
//
//  Created by David Hsieh on 5/4/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Droplet.h"



@protocol DropletManagerDelegate <NSObject>


@optional
-(void)connectionTestFinishedWithResult:(NSDictionary*)result;


@end // end of delegate protocol






@interface DropletManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {


    
}


@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSMutableArray *droplets;
@property (nonatomic, weak) id<DropletManagerDelegate> delegate;


+ (id)sharedManager;


- (void)refreshDroplets;
- (void)rebootDroplet:(Droplet*)droplet;
- (void)shutdownDroplet:(Droplet*)droplet;
- (void)turnOnDroplet:(Droplet*)droplet;
- (void)deleteDroplet:(Droplet*)droplet;

- (void) requestForAction:(NSString*)action onDroplet:(Droplet*)droplet;

- (void) testConnection;
- (BOOL)isConnectionSuccessful;


@end