***REMOVED***
***REMOVED***  LaunchAtLoginController.m
***REMOVED***
***REMOVED***  Copyright 2011 Tomáš Znamenáček
***REMOVED***  Copyright 2010 Ben Clark-Robinson
***REMOVED***
***REMOVED***  Permission is hereby granted, free of charge, to any person obtaining
***REMOVED***  a copy of this software and associated documentation files (the ‘Software’),
***REMOVED***  to deal in the Software without restriction, including without limitation
***REMOVED***  the rights to use, copy, modify, merge, publish, distribute, sublicense,
***REMOVED***  and/or sell copies of the Software, and to permit persons to whom the
***REMOVED***  Software is furnished to do so, subject to the following conditions:
***REMOVED***
***REMOVED***  The above copyright notice and this permission notice shall be
***REMOVED***  included in all copies or substantial portions of the Software.
***REMOVED***
***REMOVED***  THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND,
***REMOVED***  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
***REMOVED***  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
***REMOVED***  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
***REMOVED***  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
***REMOVED***  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
***REMOVED***  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LaunchAtLoginController.h"

static NSString *const StartAtLoginKey = @"launchAtLogin";

@interface LaunchAtLoginController ()
@property(assign) LSSharedFileListRef loginItems;
@end

@implementation LaunchAtLoginController
@synthesize loginItems;

#pragma mark Change Observing

void sharedFileListDidChange(LSSharedFileListRef inList, void *context)
{
    LaunchAtLoginController *self = (__bridge id) context;
    [self willChangeValueForKey:StartAtLoginKey];
    [self didChangeValueForKey:StartAtLoginKey];
}

#pragma mark Initialization

- (id) init
{
    self = [super init];
    loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListAddObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, (voidPtr)CFBridgingRetain(self));
    return self;
}

- (void) dealloc
{
    LSSharedFileListRemoveObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, (__bridge void *)(self));
    CFRelease(loginItems);
}

#pragma mark Launch List Control

- (LSSharedFileListItemRef) findItemWithURL: (NSURL*) wantedURL inFileList: (LSSharedFileListRef) fileList
{
    if (wantedURL == NULL || fileList == NULL)
        return NULL;

    NSArray *listSnapshot = (__bridge NSArray *)(LSSharedFileListCopySnapshot(fileList, NULL));
    for (id itemObject in listSnapshot) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef) itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)(wantedURL)))
        {
            CFRelease(currentItemURL);
            return item;
        }
        if (currentItemURL)
            CFRelease(currentItemURL);
    }

    return NULL;
}

- (BOOL) willLaunchAtLogin: (NSURL*) itemURL
{
    return !![self findItemWithURL:itemURL inFileList:loginItems];
}

- (void) setLaunchAtLogin: (BOOL) enabled forURL: (NSURL*) itemURL
{
    LSSharedFileListItemRef appItem = [self findItemWithURL:itemURL inFileList:loginItems];
    if (enabled && !appItem) {
        LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
            NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
    } else if (!enabled && appItem)
        LSSharedFileListItemRemove(loginItems, appItem);
}

#pragma mark Basic Interface

- (NSURL*) appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void) setLaunchAtLogin: (BOOL) enabled
{
    [self willChangeValueForKey:StartAtLoginKey];
    [self setLaunchAtLogin:enabled forURL:[self appURL]];
    [self didChangeValueForKey:StartAtLoginKey];
}

- (BOOL) launchAtLogin
{
    return [self willLaunchAtLogin:[self appURL]];
}

@end
