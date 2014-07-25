//
//  DropletManager.m
//  DODropletManager
//
//  Created by David Hsieh on 5/4/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "DropletManager.h"
#import "KeychainAccess.h"

@implementation DropletManager {
    NSMutableData *responseData;
    NSURLConnection *dropletsConnection, *regionsConnection, *imagesConnection, *testConnection;
    NSURLConnection *rebootDropletConnection, *shutdownDropletConnection, *turnOnDropletConnection, *deleteDropletConnection;
    NSMutableDictionary *regions;
    NSMutableDictionary *images;
    
}


#pragma mark Singleton Methods

+ (id)sharedManager {
    static DropletManager *sharedDropletManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDropletManager = [[self alloc] init];
    });
    return sharedDropletManager;
}

- (id)init {
    if (self = [super init]) {
        _droplets = [[NSMutableArray alloc] init];
        
        NSString *accessToken, *refreshToken;
        NSError *err;
        
        if([KeychainAccess getAccessToken:&accessToken andRefreshToken:&refreshToken error:nil]) {
            DLog(@"AccessToken retreival success? ")
            _accessToken = accessToken;
            _refreshToken = refreshToken;
        } else {
            DLog(@"Error loading keys");
        }
        
        [self requestDroplets];

        

    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}



#pragma mark -
#pragma mark Communication methods


- (void) testConnection {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/regions"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    
    testConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(testConnection) {
        responseData = [[NSMutableData alloc] init];
        DLog(@"Connection started for :%@", urlRequest);
    } else {
        DLog(@"connection failed");
    }
    
}

- (void) requestRegions {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/regions"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];

    
    regionsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(regionsConnection) {
        responseData = [[NSMutableData alloc] init];
        DLog(@"Connection started for :%@", urlRequest);
    } else {
        DLog(@"connection failed");
    }
    
}

- (void) requestImages {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/images"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    
    
    imagesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(imagesConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}

- (void) requestDroplets {
    DLog(@"Request droplets");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/droplets"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    DLog(@"Auth token %@", _accessToken);
    

    

    

    
        DLog(@"THE REQUEST %@", [urlRequest allHTTPHeaderFields]);
    
    dropletsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(dropletsConnection) {
        responseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
    
}

//- (void) requestRebootForDroplet:(Droplet*)droplet {
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/reboot/?client_id=%@&api_key=%@", droplet.dropletID, _clientID, _APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    rebootDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    
//    if(rebootDropletConnection) {
//        responseData = [[NSMutableData alloc] init];
//    } else {
//        DLog(@"connection failed");
//    }
//}
//
//- (void) requestShutdownForDroplet:(Droplet*)droplet {
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/shutdown/?client_id=%@&api_key=%@", droplet.dropletID, _clientID, _APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    shutdownDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    
//    if(shutdownDropletConnection) {
//        responseData = [[NSMutableData alloc] init];
//    } else {
//        DLog(@"connection failed");
//    }
//    
//}
//
//- (void) requestTurnOnForDroplet:(Droplet*)droplet {
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/power_on/?client_id=%@&api_key=%@", droplet.dropletID, _clientID, _APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    turnOnDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    
//    DLog(@"Request turnOn %@", urlRequest.URL);
//    
//    if(turnOnDropletConnection) {
//        responseData = [[NSMutableData alloc] init];
//    } else {
//        DLog(@"connection failed");
//    }
//}
//
//- (void)requestDeleteForDroplet:(Droplet*)droplet
//{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%@/destroy/?client_id=%@&api_key=%@&scrub_data=true", droplet.dropletID, _clientID, _APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    deleteDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    responseData = nil;
    
    DLog(@"connection error");
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dropletsFailed"
     object:self];

}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSUTF8StringEncoding
                          error:&error];
    

    
    if(json != nil)
    {
        if (connection == testConnection) {
            
            // Call test connection finished delegate method
            if (self.delegate && [self.delegate respondsToSelector:@selector(connectionTestFinishedWithResult:)]) {
                [self.delegate connectionTestFinishedWithResult:json];
            }
            
        } else if (connection == dropletsConnection) {
            
            DLog(@"Droplet Connection loaded %@", json );
            
            
            NSArray *tempDropletsArray = [json objectForKey:@"droplets"];
            _droplets = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dropletDictionary in tempDropletsArray) {
                Droplet *droplet = [[Droplet alloc] initWithDictionary:dropletDictionary];
                [_droplets addObject:droplet];
            }
            


            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dropletsLoaded"
             object:self];
            

        } else  if (connection == regionsConnection) {
            NSArray *tempRegionsArray = [json objectForKey:@"regions"];
            regions = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary *region in tempRegionsArray) {
                NSString *regionID = [region objectForKey:@"id"];
                NSString *regionName = [region objectForKey:@"name"];
                
                [regions setObject:regionName forKey:regionID];
            }
            
//            [self requestImages];
        } else  if (connection == imagesConnection) {
            NSArray *tempImagesArray = [json objectForKey:@"images"];
            images = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary *image in tempImagesArray) {
                NSString *imageID = [image objectForKey:@"id"];
                NSString *distro = [image objectForKey:@"name"];
                
                [images setObject:distro forKey:imageID];
            }
            
//            [self requestDroplets];
        } else  if (connection == rebootDropletConnection) {
            DLog(@"Result status %@", [json objectForKey:@"status"]);

        } else  if (connection == shutdownDropletConnection) {
            DLog(@"Result status %@", json);

        } else  if (connection == turnOnDropletConnection) {
            DLog(@"Result status %@", json);

        } else if (connection == deleteDropletConnection) {
            [self refreshDroplets];
        }
    }
}


- (void)refreshDroplets {
    DLog(@"Refresh droplets");
    [self requestDroplets];

}

- (void)rebootDroplet:(Droplet*)droplet {
//    [self requestRebootForDroplet:droplet];
}

- (void)shutdownDroplet:(Droplet*)droplet {
//    [self requestShutdownForDroplet:droplet];
}

- (void)turnOnDroplet:(Droplet*)droplet {
//    [self requestTurnOnForDroplet:droplet];
}

- (void)deleteDroplet:(Droplet *)droplet
{
//    [self requestDeleteForDroplet:droplet];
}


@end
