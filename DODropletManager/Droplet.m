//
//  Droplet.m
//  DODropletManager
//
//  Created by David Hsieh on 4/27/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "Droplet.h"

@implementation Droplet

- (id) initWithDictionary:(NSDictionary*) dictionary {
    
    int index = 0;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"publicIPs"] boolValue]) index = 1;

    if (self = [super init]) {
        
        DLog(@"Dictionary: %@", dictionary);
        
        _name = [dictionary objectForKey:@"name"];
        _ip = [[[[dictionary objectForKey:@"networks"] objectForKey:@"v4"] objectAtIndex:index] objectForKey:@"ip_address"];
        _dropletID = [dictionary objectForKey:@"id"];
        _createdAt = [dictionary objectForKey:@"created_at"];
        _status = [[dictionary objectForKey:@"status"] uppercaseString];
        
        _region = [[dictionary objectForKey:@"region"] objectForKey:@"name"];
        _distro = [[dictionary objectForKey:@"image"] objectForKey:@"name"];
        
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
