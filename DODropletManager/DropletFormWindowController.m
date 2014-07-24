//
//  DropletFormWindowController.m
//  DODropletManager
//
//  Created by Adam Tootle on 4/28/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import "DropletFormWindowController.h"
#import "NSString+URLEncode.h"
#import "KeychainAccess.h"
#import "DropletManager.h"

@interface DropletFormWindowController ()

@end

@implementation DropletFormWindowController {
    NSURLConnection *availableImagesConnection;
    NSURLConnection *availableSizesConnection;
    NSURLConnection *createNewDropletConnection;
    NSMutableData *imagesResponseData;
    NSMutableData *sizesResponseData;
    NSMutableData *createDropletResponseData;
    NSArray *availableImages;
    NSArray *availableSizes;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        imagesResponseData = [[NSMutableData alloc] init];
        sizesResponseData = [[NSMutableData alloc] init];
        createDropletResponseData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
//    NSString *client;
//    NSString *key;
    
//    if([KeychainAccess getClientId: &client andAPIKey: &key error: nil]) {
//        clientID = client;
//        APIKey = key;
//    }
    
    [self.availableImagesPopup addItemWithTitle:@"Select image..."];
    [self loadAvailableImages];
    
    [self.availableRegionsPopup addItemWithTitle:@"Select region..."];
    
    [self.availableSizePopup addItemWithTitle:@"Choose size..."];
    [self loadAvailableSizes];
}

- (void)createDroplet:(id)sender
{
    NSInteger selectedSizeIndex = [self.availableSizePopup indexOfItem:self.availableSizePopup.selectedItem] - 1;
    NSNumber *sizeID = availableSizes[selectedSizeIndex][@"id"];
    
    NSInteger selectedImageIndex = [self.availableImagesPopup indexOfItem:self.availableImagesPopup.selectedItem] - 1;
    NSNumber *imageID = availableImages[selectedImageIndex][@"id"];
    
    NSInteger selectedRegionIndex = [self.availableRegionsPopup indexOfItem:self.availableRegionsPopup.selectedItem] - 1;
    NSNumber *regionID = availableImages[selectedImageIndex][@"region_slugs"][selectedRegionIndex];
    
//    NSString *path = [NSString stringWithFormat:@"https://api.digitalocean.com/droplets/new/?client_id=%@&api_key=%@&name=%@&size_id=%@&image_id=%@&region_slug=%@", clientID, APIKey, [self.dropletNameField.stringValue urlEncode], sizeID, imageID, regionID];
    
//    NSURL *url = [NSURL URLWithString:path];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
//    createNewDropletConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)cancelDroplet:(id)sender
{
    [self close];
}

- (void)didEndSuccessAlert
{
    [self close];
};

- (void)loadAvailableImages
{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/images/?filter=global&client_id=%@&api_key=%@", clientID, APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
//    availableImagesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)loadAvailableSizes
{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.digitalocean.com/sizes/?client_id=%@&api_key=%@", clientID, APIKey]];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
//    availableSizesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)didSelectImage:(id)sender
{
    if([sender isEqual:self.availableImagesPopup])
    {
        [self.availableRegionsPopup removeAllItems];
        [self.availableRegionsPopup addItemWithTitle:@"Select region..."];
        NSInteger selectedImageIndex = [self.availableImagesPopup indexOfItem:self.availableImagesPopup.selectedItem];
        
        for(NSString *slug in availableImages[selectedImageIndex][@"region_slugs"])
        {
            [self.availableRegionsPopup addItemWithTitle:slug];
        }
    }
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([connection isEqual:availableImagesConnection])
    {
        [imagesResponseData setLength:0];
    }
    else if([connection isEqual:availableSizesConnection])
    {
        [sizesResponseData setLength:0];
    }
    else if([connection isEqual:createNewDropletConnection])
    {
        [createDropletResponseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if([connection isEqual:availableImagesConnection])
    {
        [imagesResponseData appendData:data];
    }
    else if([connection isEqual:availableSizesConnection])
    {
        [sizesResponseData appendData:data];
    }
    else if([connection isEqual:createNewDropletConnection])
    {
        [createDropletResponseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary* json;
    
    if([connection isEqual:availableImagesConnection])
    {
        json = [NSJSONSerialization
                JSONObjectWithData:imagesResponseData
                options:NSUTF8StringEncoding
                error:&error];
    }
    else if([connection isEqual:availableSizesConnection])
    {
        json = [NSJSONSerialization
                JSONObjectWithData:sizesResponseData
                options:NSUTF8StringEncoding
                error:&error];
    }
    else if([connection isEqual:createNewDropletConnection])
    {
        json = [NSJSONSerialization
                JSONObjectWithData:createDropletResponseData
                options:NSUTF8StringEncoding
                error:&error];
    }
    
    if([connection isEqual:availableImagesConnection] && json != nil)
    {
        availableImages = [NSArray arrayWithArray:json[@"images"]];
        for(NSDictionary *image in availableImages)
        {
            [self.availableImagesPopup addItemWithTitle:image[@"name"]];
        }
    }
    else if([connection isEqual:availableSizesConnection] && json != nil)
    {
        availableSizes = [NSArray arrayWithArray:json[@"sizes"]];
        for(NSDictionary *image in availableSizes)
        {
            [self.availableSizePopup addItemWithTitle:image[@"name"]];
        }
    }
    else if([connection isEqual:createNewDropletConnection])
    {
        NSLog(@"%@", json);
        
        if(json[@"error_message"] != nil)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                             defaultButton:@"Ok"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", json[@"error_message"]];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:nil
                                contextInfo:nil];
        }
        else
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Success!"
                                             defaultButton:@"Ok"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Droplet created successfully!"];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:@selector(didEndSuccessAlert)
                                contextInfo:nil];
            
            [[DropletManager sharedManager] refreshDroplets];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", [error description]);
}

@end
