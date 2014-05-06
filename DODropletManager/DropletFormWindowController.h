//
//  DropletFormWindowController.h
//  DODropletManager
//
//  Created by Adam Tootle on 4/28/14.
//  Copyright (c) 2014 David Hsieh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DropletFormWindowController : NSWindowController <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property(nonatomic, strong) IBOutlet NSTextField *dropletNameField;
@property(nonatomic, strong) IBOutlet NSPopUpButton *availableImagesPopup;
@property(nonatomic, strong) IBOutlet NSPopUpButton *availableRegionsPopup;
@property(nonatomic, strong) IBOutlet NSPopUpButton *availableSizePopup;

- (IBAction)didSelectImage:(id)sender;
- (IBAction)createDroplet:(id)sender;
- (IBAction)cancelDroplet:(id)sender;

@end
