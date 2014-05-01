***REMOVED***
***REMOVED***  LaunchAtLoginController.h
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

@interface LaunchAtLoginController : NSObject {}

@property(assign) BOOL launchAtLogin;

- (BOOL) willLaunchAtLogin: (NSURL*) itemURL;
- (void) setLaunchAtLogin: (BOOL) enabled forURL: (NSURL*) itemURL;

@end
