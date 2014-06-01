/*
 * iTerm.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class iTermItem, iTermITermApplication, iTermColor, iTermDocument, iTermWindow, iTermAttributeRun, iTermCharacter, iTermParagraph, iTermText, iTermAttachment, iTermWord, iTermSession, iTermTerminal, iTermPrintSettings;

enum iTermSavo {
	iTermSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */,
	iTermSavoNo = 'no  ' /* Do not save the file. */,
	iTermSavoYes = 'yes ' /* Save the file. */
};
typedef enum iTermSavo iTermSavo;

enum iTermEnum {
	iTermEnumStandard = 'lwst' /* Standard PostScript error handling */,
	iTermEnumDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum iTermEnum iTermEnum;



/*
 * Standard Suite
 */

***REMOVED*** A scriptable object.
@interface iTermItem : SBObject

@property (copy) NSDictionary *properties;  ***REMOVED*** All of the object's properties.

- (void) closeSaving:(iTermSavo)saving savingIn:(NSURL *)savingIn;  ***REMOVED*** Close an object.
- (void) delete;  ***REMOVED*** Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  ***REMOVED*** Copy object(s) and put the copies at a new location.
- (BOOL) exists;  ***REMOVED*** Verify if an object exists.
- (void) moveTo:(SBObject *)to;  ***REMOVED*** Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  ***REMOVED*** Save an object.
- (void) execCommand:(NSString *)command;  ***REMOVED*** Executes a command in a session (attach a trailing space for commands without carriage return)
- (iTermSession *) launchSession:(NSString *)session;  ***REMOVED*** Launches a default or saved session
- (void) select;  ***REMOVED*** Selects a specified session
- (void) terminate;  ***REMOVED*** Terminates a session
- (void) writeContentsOfFile:(NSString *)contentsOfFile text:(NSString *)text;  ***REMOVED*** Writes text or file contents into a session

@end

***REMOVED*** An application's top level scripting object.
@interface iTermITermApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (readonly) BOOL frontmost;  ***REMOVED*** Is this the frontmost (active) application?
@property (copy, readonly) NSString *name;  ***REMOVED*** The name of the application.
@property (copy, readonly) NSString *version;  ***REMOVED*** The version of the application.

- (iTermDocument *) open:(NSURL *)x;  ***REMOVED*** Open an object.
- (void) print:(NSURL *)x printDialog:(BOOL)printDialog withProperties:(iTermPrintSettings *)withProperties;  ***REMOVED*** Print an object.
- (void) quitSaving:(iTermSavo)saving;  ***REMOVED*** Quit an application.

@end

***REMOVED*** A color.
@interface iTermColor : iTermItem


@end

***REMOVED*** A document.
@interface iTermDocument : iTermItem

@property (readonly) BOOL modified;  ***REMOVED*** Has the document been modified since the last save?
@property (copy) NSString *name;  ***REMOVED*** The document's name.
@property (copy) NSString *path;  ***REMOVED*** The document's path.


@end

***REMOVED*** A window.
@interface iTermWindow : iTermItem

@property NSRect bounds;  ***REMOVED*** The bounding rectangle of the window.
@property (readonly) BOOL closeable;  ***REMOVED*** Whether the window has a close box.
@property (copy, readonly) iTermDocument *document;  ***REMOVED*** The document whose contents are being displayed in the window.
@property (readonly) BOOL floating;  ***REMOVED*** Whether the window floats.
- (NSInteger) id;  ***REMOVED*** The unique identifier of the window.
@property NSInteger index;  ***REMOVED*** The index of the window, ordered front to back.
@property (readonly) BOOL miniaturizable;  ***REMOVED*** Whether the window can be miniaturized.
@property BOOL miniaturized;  ***REMOVED*** Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  ***REMOVED*** Whether the window is the application's current modal window.
@property (copy) NSString *name;  ***REMOVED*** The full title of the window.
@property (readonly) BOOL resizable;  ***REMOVED*** Whether the window can be resized.
@property (readonly) BOOL titled;  ***REMOVED*** Whether the window has a title bar.
@property BOOL visible;  ***REMOVED*** Whether the window is currently visible.
@property (readonly) BOOL zoomable;  ***REMOVED*** Whether the window can be zoomed.
@property BOOL zoomed;  ***REMOVED*** Whether the window is currently zoomed.


@end



/*
 * Text Suite
 */

***REMOVED*** This subdivides the text into chunks that all have the same attributes.
@interface iTermAttributeRun : iTermItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  ***REMOVED*** The color of the first character.
@property (copy) NSString *font;  ***REMOVED*** The name of the font of the first character.
@property NSInteger size;  ***REMOVED*** The size in points of the first character.


@end

***REMOVED*** This subdivides the text into characters.
@interface iTermCharacter : iTermItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  ***REMOVED*** The color of the first character.
@property (copy) NSString *font;  ***REMOVED*** The name of the font of the first character.
@property NSInteger size;  ***REMOVED*** The size in points of the first character.


@end

***REMOVED*** This subdivides the text into paragraphs.
@interface iTermParagraph : iTermItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  ***REMOVED*** The color of the first character.
@property (copy) NSString *font;  ***REMOVED*** The name of the font of the first character.
@property NSInteger size;  ***REMOVED*** The size in points of the first character.


@end

***REMOVED*** Rich (styled) text
@interface iTermText : iTermItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  ***REMOVED*** The color of the first character.
@property (copy) NSString *font;  ***REMOVED*** The name of the font of the first character.
@property NSInteger size;  ***REMOVED*** The size in points of the first character.


@end

***REMOVED*** Represents an inline text attachment.  This class is used mainly for make commands.
@interface iTermAttachment : iTermText

@property (copy) NSString *fileName;  ***REMOVED*** The path to the file for the attachment


@end

***REMOVED*** This subdivides the text into words.
@interface iTermWord : iTermItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  ***REMOVED*** The color of the first character.
@property (copy) NSString *font;  ***REMOVED*** The name of the font of the first character.
@property NSInteger size;  ***REMOVED*** The size in points of the first character.


@end



/*
 * iTerm Suite
 */

***REMOVED*** Main application class
@interface iTermITermApplication (ITermSuite)

- (SBElementArray *) terminals;

@property (copy) iTermTerminal *currentTerminal;  ***REMOVED*** currently active terminal

@end

***REMOVED*** A terminal session
@interface iTermSession : iTermItem

@property (copy) NSColor *backgroundColor;  ***REMOVED*** Background color
@property (copy) NSString *backgroundImagePath;  ***REMOVED*** Path to background image
@property (copy) NSColor *boldColor;  ***REMOVED*** Bold color
@property (copy, readonly) NSString *contents;  ***REMOVED*** text of the session
@property (copy) NSColor *cursorColor;  ***REMOVED*** Cursor color
@property (copy) NSColor *cursor_textColor;  ***REMOVED*** Cursor text color
@property (copy) NSColor *foregroundColor;  ***REMOVED*** Foreground color
- (NSString *) id;  ***REMOVED*** id of session; set to tty name
@property (copy) NSString *name;  ***REMOVED*** Name of this session
@property NSInteger number;  ***REMOVED*** index of session
@property (copy) NSColor *selectedTextColor;  ***REMOVED*** Selected text color
@property (copy) NSColor *selectionColor;  ***REMOVED*** Selection color
@property double transparency;  ***REMOVED*** Transparency (0-1)
@property (copy, readonly) NSString *tty;  ***REMOVED*** tty device of session


@end

***REMOVED*** A pseudo terminal
@interface iTermTerminal : iTermItem

- (SBElementArray *) sessions;

@property BOOL antiAlias;  ***REMOVED*** Anti alias for window
@property (copy) iTermSession *currentSession;  ***REMOVED*** current session in the terminal
@property NSInteger numberOfColumns;  ***REMOVED*** Number of columns
@property NSInteger numberOfRows;  ***REMOVED*** Number of rows


@end



/*
 * Type Definitions
 */

@interface iTermPrintSettings : SBObject

@property NSInteger copies;  ***REMOVED*** the number of copies of a document to be printed
@property BOOL collating;  ***REMOVED*** Should printed copies be collated?
@property NSInteger startingPage;  ***REMOVED*** the first page of the document to be printed
@property NSInteger endingPage;  ***REMOVED*** the last page of the document to be printed
@property NSInteger pagesAcross;  ***REMOVED*** number of logical pages laid across a physical page
@property NSInteger pagesDown;  ***REMOVED*** number of logical pages laid out down a physical page
@property (copy) NSDate *requestedPrintTime;  ***REMOVED*** the time at which the desktop printer should print the document
@property iTermEnum errorHandling;  ***REMOVED*** how errors are handled
@property (copy) NSString *faxNumber;  ***REMOVED*** for fax number
@property (copy) NSString *targetPrinter;  ***REMOVED*** for target printer

- (void) closeSaving:(iTermSavo)saving savingIn:(NSURL *)savingIn;  ***REMOVED*** Close an object.
- (void) delete;  ***REMOVED*** Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  ***REMOVED*** Copy object(s) and put the copies at a new location.
- (BOOL) exists;  ***REMOVED*** Verify if an object exists.
- (void) moveTo:(SBObject *)to;  ***REMOVED*** Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  ***REMOVED*** Save an object.
- (void) execCommand:(NSString *)command;  ***REMOVED*** Executes a command in a session (attach a trailing space for commands without carriage return)
- (iTermSession *) launchSession:(NSString *)session;  ***REMOVED*** Launches a default or saved session
- (void) select;  ***REMOVED*** Selects a specified session
- (void) terminate;  ***REMOVED*** Terminates a session
- (void) writeContentsOfFile:(NSString *)contentsOfFile text:(NSString *)text;  ***REMOVED*** Writes text or file contents into a session

@end

