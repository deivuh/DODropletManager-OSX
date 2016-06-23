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
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        _accountName = [userDefaults objectForKey:@"accountName"];
        
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
        testResponseData = [[NSMutableData alloc] init];
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
        regionsResponseData = [[NSMutableData alloc] init];
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
        imagesResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}

- (void) requestSizes {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/sizes"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    
    sizesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(sizesConnection) {
        sizesResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}

- (void) requestDroplets {
    DLog(@"Request droplets");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/droplets?page=1&per_page=1000"]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    DLog(@"Auth token %@", _accessToken);
    

    

    

    
    DLog(@"THE REQUEST %@", [urlRequest allHTTPHeaderFields]);
    
    dropletsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if(dropletsConnection) {
        dropletsResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
    
}

- (void) requestForAction:(NSString*)action onDroplet:(Droplet*)droplet {
    NSError *error;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/droplets/%@/actions", droplet.dropletID]];
   
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    DLog(@"Auth line %@", [NSString stringWithFormat:@"Bearer %@", _accessToken]);
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary* jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    action, @"type",
                                    nil];
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    DLog(@"Sending request %@", [urlRequest description]);
    
    rebootDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    
    
    if(rebootDropletConnection) {
        rebootDropletResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
}



- (void)requestDeleteForDroplet:(Droplet*)droplet
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/v2/droplets/%@/", droplet.dropletID]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    [urlRequest setHTTPMethod:@"DELETE"];
    
    DLog(@"DELETE FIELDS %@", [urlRequest allHTTPHeaderFields]);
    
    deleteDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    
    if(deleteDropletConnection) {
        deleteDropletResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }

}

- (void)requestCreateDroplet:(Droplet*)droplet {
    
    
    NSError *error;
    
    NSURL *url = [NSURL URLWithString:@"https://api.digitalocean.com/v2/droplets/"];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    DLog(@"Auth line %@", [NSString stringWithFormat:@"Bearer %@", _accessToken]);
    
    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary* jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    droplet.name, @"name",
                                    droplet.regionID, @"region",
                                    droplet.sizeID, @"size",
                                    droplet.imageID, @"image",
                                    nil];
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    DLog(@"Sending request %@", [urlRequest description]);
    
    createDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    
    
    if(createDropletConnection) {
        createDropletResponseData = [[NSMutableData alloc] init];
    } else {
        DLog(@"connection failed");
    }
    
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if (connection == dropletsConnection) {
        [dropletsResponseData setLength:0];
    } else if (connection == regionsConnection) {
        [regionsResponseData setLength:0];
    } else if (connection == imagesConnection) {
        [imagesResponseData setLength:0];
    } else if (connection == testConnection) {
        [testResponseData setLength:0];
    } else if (connection == sizesConnection) {
        [sizesResponseData setLength:0];
    } else if (connection == rebootDropletConnection) {
        [rebootDropletResponseData setLength:0];
    } else if (connection == shutdownDropletConnection) {
        [shutdownDropletResponseData setLength:0];
    } else if (connection == turnOnDropletConnection) {
        [turnOnDropletResponseData setLength:0];
    } else if (connection == deleteDropletConnection) {
        [deleteDropletResponseData setLength:0];
    } else if (connection == createDropletConnection) {
        [createDropletResponseData setLength:0];
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == dropletsConnection) {
        [dropletsResponseData appendData:data];
    } else if (connection == regionsConnection) {
        [regionsResponseData appendData:data];
    } else if (connection == imagesConnection) {
        [imagesResponseData appendData:data];
    } else if (connection == testConnection) {
        [testResponseData appendData:data];
    } else if (connection == sizesConnection) {
        [sizesResponseData appendData:data];
    } else if (connection == rebootDropletConnection) {
        [rebootDropletResponseData appendData:data];
    } else if (connection == shutdownDropletConnection) {
        [shutdownDropletResponseData appendData:data];
    } else if (connection == turnOnDropletConnection) {
        [turnOnDropletResponseData appendData:data];
    } else if (connection == deleteDropletConnection) {
        [deleteDropletResponseData appendData:data];
    } else if (connection == createDropletConnection) {
        [createDropletResponseData appendData:data];
    }
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    responseData = nil;
    
    DLog(@"connection error");
    
    if (connection == dropletsConnection) {
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"dropletsFailed"
         object:self];
    }
    

}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    
    NSDictionary* json;
    
    
    if (connection == dropletsConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:dropletsResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
        DLog(@"JSON %@", json);

    } else if (connection == regionsConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:regionsResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == imagesConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:imagesResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == testConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:testResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == sizesConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:sizesResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == rebootDropletConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:rebootDropletResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == shutdownDropletConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:shutdownDropletResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == turnOnDropletConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:turnOnDropletResponseData
         options:NSUTF8StringEncoding
         error:&error];
        
    } else if (connection == deleteDropletConnection) {
        json = [NSJSONSerialization
         JSONObjectWithData:deleteDropletResponseData
         options:NSUTF8StringEncoding
         error:&error];
    } else if (connection == createDropletConnection) {
        json = [NSJSONSerialization
                JSONObjectWithData:createDropletResponseData
                options:NSUTF8StringEncoding
                error:&error];
    }
    

    
    if(json != nil)
    {
        if (connection == testConnection) {
            
            // Call test connection finished delegate method
            if (self.delegate && [self.delegate respondsToSelector:@selector(connectionTestFinishedWithResult:)]) {
                [self.delegate connectionTestFinishedWithResult:json];
            }
            
        } else if (connection == dropletsConnection) {
            
            if ([json objectForKey:@"Error"]) {
                
                DLog(@"Error: %@", [json objectForKey:@"Error"]);
                connectionSuccessful = NO;
                return;
            }
            
            DLog(@"Droplet Connection loaded %@", json );
            
            
            NSArray *tempDropletsArray = [json objectForKey:@"droplets"];
            _droplets = [[NSMutableArray alloc] init];

            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
            NSArray *sortedDropletsArray = [tempDropletsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

            for (NSDictionary *dropletDictionary in sortedDropletsArray) {
                Droplet *droplet = [[Droplet alloc] initWithDictionary:dropletDictionary];
                [_droplets addObject:droplet];
            }
            


            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dropletsLoaded"
             object:self];
            
            connectionSuccessful = YES;

            

        } else  if (connection == regionsConnection) {
            if ([json objectForKey:@"regions"]) {
                
                _regions = [json objectForKey:@"regions"];
            }
            
            

        } else  if (connection == imagesConnection) {
            if ([json objectForKey:@"images"]) {
                _images = [json objectForKey:@"images"];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"imagesLoaded"
                 object:nil];
            }
            
        } else if (connection == sizesConnection) {
            if ([json objectForKey:@"sizes"]) {
                _sizes = [json objectForKey:@"sizes"];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"sizesLoaded"
                 object:nil];
            }
            

        } else  if (connection == rebootDropletConnection) {
            DLog(@"Results :%@", json);

        } else  if (connection == shutdownDropletConnection) {
            DLog(@"Result status %@", json);

        } else  if (connection == turnOnDropletConnection) {
            DLog(@"Result status %@", json);

        } else if (connection == deleteDropletConnection) {
            DLog(@"Result status %@", json);
        } else if (connection == createDropletConnection) {
            DLog(@"Result status %@", json);
        }
    }
}


- (void)refreshDroplets {
    DLog(@"Refresh droplets");
    [self requestDroplets];

}

- (void)rebootDroplet:(Droplet*)droplet {
    [self requestForAction:@"reboot" onDroplet:droplet];
}

- (void)shutdownDroplet:(Droplet*)droplet {
    [self requestForAction:@"shutdown" onDroplet:droplet];
}

- (void)turnOnDroplet:(Droplet*)droplet {
    [self requestForAction:@"power_on" onDroplet:droplet];
}

- (void)deleteDroplet:(Droplet *)droplet
{
    [self requestDeleteForDroplet:droplet];
}

- (BOOL)isConnectionSuccessful {
    return connectionSuccessful;
}


@end
