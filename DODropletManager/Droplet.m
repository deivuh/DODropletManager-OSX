//
//  Droplet.m
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "Droplet.h"

@implementation Droplet

- (id) initWithDictionary:(NSDictionary*) dictionary regions:(NSDictionary*) regions andImages:(NSDictionary*)images{
    
    if (self = [super init]) {
        
        DLog(@"Dictionary: %@", dictionary);
        
        _name = [dictionary objectForKey:@"name"];
        _ip = [dictionary objectForKey:@"ip_address"];
        _dropletID = [dictionary objectForKey:@"id"];
        _imageID = [dictionary objectForKey:@"image_id"];
        _sizeID = [dictionary objectForKey:@"size_id"];
        _regionID = [dictionary objectForKey:@"region_id"];
        _privateIP = [dictionary objectForKey:@"private_ip_address"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        _status = [[dictionary objectForKey:@"status"] uppercaseString];
        
        _region = [regions objectForKey:_regionID];
        _distro = [images objectForKey:_imageID];
        
        _backupActive = (BOOL)[dictionary valueForKey:@"backups_active"];
        if ([[_status uppercaseString] isEqualToString:@"ACTIVE"]) {
            _active = YES;
        } else {
            _active = NO;
        }
        
        _locked = (BOOL)[dictionary valueForKey:@"locked"];
        
        
        
    }
    
    return self;
}

@end
