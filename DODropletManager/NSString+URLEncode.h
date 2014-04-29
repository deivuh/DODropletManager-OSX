***REMOVED***
***REMOVED***  NSString+UrlEncode.h
***REMOVED***
***REMOVED***  Created by Kevin Renskers on 31-10-13.
***REMOVED***  Copyright (c) 2013 Kevin Renskers. All rights reserved.
***REMOVED***

#import <Foundation/Foundation.h>

@interface NSString (UrlEncode)

- (NSString *)urlEncode;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)urlDecode;
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;

@end