//
//  AppDelegate.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/15/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define WEEKLY 0l
#define DAILY  1l
#define HOURLY 2l

@interface AppDelegate : NSObject <NSApplicationDelegate> {

    IBOutlet NSMenu * statusMenu;
    NSStatusItem    * statusItem;
    NSImage         * statusImage;
    NSImage         * statusSelected;
    NSImage         * downIcon;
    
    IBOutlet NSWindow          * optionWindow;
    
    IBOutlet NSPopUpButton     * serverChoice;
    IBOutlet NSTextField       * destField;
    IBOutlet NSTextField       * usernameField;
    IBOutlet NSSecureTextField * passwordField;
    IBOutlet NSTextField       * sourceField;
    
    IBOutlet NSPopUpButton     * syncFreq;
    
    IBOutlet NSButton          * save;
    
    NSTimer * delay;
    
    BOOL isSyncing;
    
}

- (IBAction)optionsSelected:(id)sender;
- (IBAction)syncSelected:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic , retain) NSTimer * delay;
@property BOOL isSyncing;

@property BOOL startAtLogin;

@end
