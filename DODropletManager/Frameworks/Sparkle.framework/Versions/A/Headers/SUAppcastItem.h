***REMOVED***
***REMOVED***  SUAppcastItem.h
***REMOVED***  Sparkle
***REMOVED***
***REMOVED***  Created by Andy Matuschak on 3/12/06.
***REMOVED***  Copyright 2006 Andy Matuschak. All rights reserved.
***REMOVED***

#ifndef SUAPPCASTITEM_H
#define SUAPPCASTITEM_H

@interface SUAppcastItem : NSObject {
	NSString *title;
	NSDate *date;
	NSString *itemDescription;
	
	NSURL *releaseNotesURL;
	
	NSString *DSASignature;	
	NSString *minimumSystemVersion;
	
	NSURL *fileURL;
	NSString *versionString;
	NSString *displayVersionString;
	
	NSDictionary *propertiesDictionary;
}

***REMOVED*** Initializes with data from a dictionary provided by the RSS class.
- initWithDictionary:(NSDictionary *)dict;

- (NSString *)title;
- (NSString *)versionString;
- (NSString *)displayVersionString;
- (NSDate *)date;
- (NSString *)itemDescription;
- (NSURL *)releaseNotesURL;
- (NSURL *)fileURL;
- (NSString *)DSASignature;
- (NSString *)minimumSystemVersion;

***REMOVED*** Returns the dictionary provided in initWithDictionary; this might be useful later for extensions.
- (NSDictionary *)propertiesDictionary;

@end

***REMOVED***
