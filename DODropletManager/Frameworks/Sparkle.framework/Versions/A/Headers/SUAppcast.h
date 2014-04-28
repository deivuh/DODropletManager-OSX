***REMOVED***
***REMOVED***  SUAppcast.h
***REMOVED***  Sparkle
***REMOVED***
***REMOVED***  Created by Andy Matuschak on 3/12/06.
***REMOVED***  Copyright 2006 Andy Matuschak. All rights reserved.
***REMOVED***

#ifndef SUAPPCAST_H
#define SUAPPCAST_H

@class SUAppcastItem;
@interface SUAppcast : NSObject {
	NSArray *items;
	NSString *userAgentString;
	id delegate;
	NSMutableData *incrementalData;
}

- (void)fetchAppcastFromURL:(NSURL *)url;
- (void)setDelegate:delegate;
- (void)setUserAgentString:(NSString *)userAgentString;

- (NSArray *)items;

@end

@interface NSObject (SUAppcastDelegate)
- (void)appcastDidFinishLoading:(SUAppcast *)appcast;
- (void)appcast:(SUAppcast *)appcast failedToLoadWithError:(NSError *)error;
@end

***REMOVED***
