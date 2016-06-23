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
    
    DropletManager *dropletManager;
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
    
    dropletManager = [DropletManager sharedManager];
    
    
    [self.availableImagesPopup addItemWithTitle:@"Select image..."];
    [self loadAvailableImages];
    
    [self.availableRegionsPopup addItemWithTitle:@"Select region..."];
    
    [self.availableSizePopup addItemWithTitle:@"Choose size..."];
    [self loadAvailableSizes];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"imagesLoaded"
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"sizesLoaded"
                                               object:nil];

}

- (IBAction)createDroplet:(id)sender
{
    NSInteger selectedSizeIndex = [self.availableSizePopup indexOfItem:self.availableSizePopup.selectedItem] - 1;
    NSString *sizeID = availableSizes[selectedSizeIndex][@"slug"];
    
    NSInteger selectedImageIndex = [self.availableImagesPopup indexOfItem:self.availableImagesPopup.selectedItem] - 1;
    NSString *imageID = availableImages[selectedImageIndex][@"id"];
    
    NSInteger selectedRegionIndex = [self.availableRegionsPopup indexOfItem:self.availableRegionsPopup.selectedItem] - 1;
    NSString *regionID = availableImages[selectedImageIndex][@"regions"][selectedRegionIndex];
    
    DLog(@"Create droplet with %@, %@, %@", sizeID, imageID, regionID);
    
    Droplet *newDroplet = [[Droplet alloc] init];
    newDroplet.name = self.dropletNameField.stringValue.urlEncode;
    newDroplet.sizeID = sizeID;
    newDroplet.imageID = imageID;
    newDroplet.regionID = regionID;
    
    [dropletManager requestCreateDroplet:newDroplet];
    
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
    
    if (dropletManager.images == nil) {
        [dropletManager requestImages];
    } else {
    

        for(NSDictionary *image in availableImages)
        {
            [self.availableImagesPopup addItemWithTitle:image[@"name"]];
        }
    }

    
}

- (void)loadAvailableSizes
{
    
    if (dropletManager.sizes == nil) {
        [dropletManager requestSizes];
    } else {
        
        for(NSDictionary *size in availableSizes)
        {
            [self.availableSizePopup addItemWithTitle:size[@"slug"]];
        }
    }
}


- (IBAction)didSelectImage:(id)sender
{
    if([sender isEqual:self.availableImagesPopup])
    {
        [self.availableRegionsPopup removeAllItems];
        [self.availableRegionsPopup addItemWithTitle:@"Select region..."];
        NSInteger selectedImageIndex = [self.availableImagesPopup indexOfItem:self.availableImagesPopup.selectedItem];
        
        for(NSString *slug in availableImages[selectedImageIndex][@"regions"])
        {
            [self.availableRegionsPopup addItemWithTitle:slug];
        }
    }
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([connection isEqual:createNewDropletConnection])
    {
        [createDropletResponseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if([connection isEqual:createNewDropletConnection])
    {
        [createDropletResponseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary* json;

    if([connection isEqual:createNewDropletConnection])
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

#pragma mark -
#pragma mark Notification methods

- (void) receivedNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"imagesLoaded"]) {
        
        availableImages = dropletManager.images;
        [self loadAvailableImages];
        DLog(@"Images Loaded");
    } else if ([[notification name] isEqualToString:@"sizesLoaded"]) {
        
        availableSizes = dropletManager.sizes;
        [self loadAvailableSizes];
        DLog(@"Sizes Loaded");
    }
}

@end
