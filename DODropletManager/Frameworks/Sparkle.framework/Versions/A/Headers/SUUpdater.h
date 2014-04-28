***REMOVED***
***REMOVED***  SUUpdater.h
***REMOVED***  Sparkle
***REMOVED***
***REMOVED***  Created by Andy Matuschak on 1/4/06.
***REMOVED***  Copyright 2006 Andy Matuschak. All rights reserved.
***REMOVED***

#ifndef SUUPDATER_H
#define SUUPDATER_H

#import <Sparkle/SUVersionComparisonProtocol.h>

@class SUUpdateDriver, SUAppcastItem, SUHost, SUAppcast;
@interface SUUpdater : NSObject {
	NSTimer *checkTimer;
	SUUpdateDriver *driver;
	
	SUHost *host;
	IBOutlet id delegate;
}

+ (SUUpdater *)sharedUpdater;
+ (SUUpdater *)updaterForBundle:(NSBundle *)bundle;
- (NSBundle *)hostBundle;

- (void)setDelegate:(id)delegate;
- delegate;

- (void)setAutomaticallyChecksForUpdates:(BOOL)automaticallyChecks;
- (BOOL)automaticallyChecksForUpdates;

- (void)setUpdateCheckInterval:(NSTimeInterval)interval;
- (NSTimeInterval)updateCheckInterval;

- (void)setFeedURL:(NSURL *)feedURL;
- (NSURL *)feedURL;

- (void)setSendsSystemProfile:(BOOL)sendsSystemProfile;
- (BOOL)sendsSystemProfile;

- (void)setAutomaticallyDownloadsUpdates:(BOOL)automaticallyDownloadsUpdates;
- (BOOL)automaticallyDownloadsUpdates;

***REMOVED*** This IBAction is meant for a main menu item. Hook up any menu item to this action,
***REMOVED*** and Sparkle will check for updates and report back its findings verbosely.
- (IBAction)checkForUpdates:sender;

***REMOVED*** This kicks off an update meant to be programmatically initiated. That is, it will display no UI unless it actually finds an update,
***REMOVED*** in which case it proceeds as usual. If the fully automated updating is turned on, however, this will invoke that behavior, and if an
***REMOVED*** update is found, it will be downloaded and prepped for installation.
- (void)checkForUpdatesInBackground;

***REMOVED*** Date of last update check. Returns null if no check has been performed.
- (NSDate*)lastUpdateCheckDate;

***REMOVED*** This begins a "probing" check for updates which will not actually offer to update to that version. The delegate methods, though,
***REMOVED*** (up to updater:didFindValidUpdate: and updaterDidNotFindUpdate:), are called, so you can use that information in your UI.
- (void)checkForUpdateInformation;

***REMOVED*** Call this to appropriately schedule or cancel the update checking timer according to the preferences for time interval and automatic checks. This call does not change the date of the next check, but only the internal NSTimer.
- (void)resetUpdateCycle;

- (BOOL)updateInProgress;
@end

@interface NSObject (SUUpdaterDelegateInformalProtocol)
***REMOVED*** This method allows you to add extra parameters to the appcast URL, potentially based on whether or not Sparkle will also be sending along the system profile. This method should return an array of dictionaries with keys: "key", "value", "displayKey", "displayValue", the latter two being specifically for display to the user.
- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile;

***REMOVED*** Use this to override the default behavior for Sparkle prompting the user about automatic update checks.
- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle;

***REMOVED*** Implement this if you want to do some special handling with the appcast once it finishes loading.
- (void)updater:(SUUpdater *)updater didFinishLoadingAppcast:(SUAppcast *)appcast;

***REMOVED*** If you're using special logic or extensions in your appcast, implement this to use your own logic for finding
***REMOVED*** a valid update, if any, in the given appcast.
- (SUAppcastItem *)bestValidUpdateInAppcast:(SUAppcast *)appcast forUpdater:(SUUpdater *)bundle;

***REMOVED*** Sent when a valid update is found by the update driver.
- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update;

***REMOVED*** Sent when a valid update is not found.
- (void)updaterDidNotFindUpdate:(SUUpdater *)update;

***REMOVED*** Sent immediately before installing the specified update.
- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)update;

***REMOVED*** Return YES to delay the relaunch until you do some processing; invoke the given NSInvocation to continue.
- (BOOL)updater:(SUUpdater *)updater shouldPostponeRelaunchForUpdate:(SUAppcastItem *)update untilInvoking:(NSInvocation *)invocation;

***REMOVED*** Called immediately before relaunching.
- (void)updaterWillRelaunchApplication:(SUUpdater *)updater;

***REMOVED*** This method allows you to provide a custom version comparator.
***REMOVED*** If you don't implement this method or return nil, the standard version comparator will be used.
- (id <SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater;

***REMOVED*** Returns the path which is used to relaunch the client after the update is installed. By default, the path of the host bundle.
- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater;

@end

***REMOVED*** Define some minimum intervals to avoid DOS-like checking attacks. These are in seconds.
***REMOVED***
#define SU_MIN_CHECK_INTERVAL 60
***REMOVED***
#define SU_MIN_CHECK_INTERVAL 60*60
***REMOVED***

***REMOVED***
#define SU_DEFAULT_CHECK_INTERVAL 60
***REMOVED***
#define SU_DEFAULT_CHECK_INTERVAL 60*60*24
***REMOVED***

***REMOVED***
