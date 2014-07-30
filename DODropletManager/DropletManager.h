//
//  DropletManager.h
//  DODropletManager
//
//  Created by David Hsieh on 5/4/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Droplet.h"


#define clientID <# Application client ID #>
#define clientSecret <# Application client secret #>

@protocol DropletManagerDelegate <NSObject>


@optional
-(void)connectionTestFinishedWithResult:(NSDictionary*)result;


@end // end of delegate protocol






@interface DropletManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {


    NSMutableData *responseData;
    NSURLConnection *dropletsConnection, *regionsConnection, *imagesConnection, *testConnection, *sizesConnection, *createDropletConnection;
    NSURLConnection *rebootDropletConnection, *shutdownDropletConnection, *turnOnDropletConnection, *deleteDropletConnection;
    NSMutableData *dropletsResponseData, *regionsResponseData, *imagesResponseData, *testResponseData, *sizesResponseData, *createDropletResponseData;
    NSMutableData *rebootDropletResponseData, *shutdownDropletResponseData, *turnOnDropletResponseData, *deleteDropletResponseData;
    
    
    BOOL connectionSuccessful;
    NSUserDefaults *userDefaults;
    
}


@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSMutableArray *droplets;
@property (nonatomic, strong) NSMutableArray *regions;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *sizes;
@property (nonatomic, weak) id<DropletManagerDelegate> delegate;


+ (id)sharedManager;


- (void)refreshDroplets;
- (void)rebootDroplet:(Droplet*)droplet;
- (void)shutdownDroplet:(Droplet*)droplet;
- (void)turnOnDroplet:(Droplet*)droplet;
- (void)deleteDroplet:(Droplet*)droplet;
- (void) requestImages;
- (void) requestRegions;
- (void) requestSizes;
- (void)requestCreateDroplet:(Droplet*)droplet;

- (void) requestForAction:(NSString*)action onDroplet:(Droplet*)droplet;

- (void) testConnection;
- (BOOL)isConnectionSuccessful;


@end