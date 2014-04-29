***REMOVED***
***REMOVED***  DropletFormWindowController.h
***REMOVED***  DODropletManager
***REMOVED***
***REMOVED***  Created by Adam Tootle on 4/28/14.
***REMOVED***  Copyright (c) 2014 David Hsieh. All rights reserved.
***REMOVED***

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
