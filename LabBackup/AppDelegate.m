//
//  AppDelegate.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/15/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "AppDelegate.h"
#import "IARSYNCWrapper.h"
#import "IATimer.h"
#import "IAMountWrapper.h"
#import "IAKeyChainWrapper.h"
#import "IALoginHandler.h"
#import "IAReachability.h"
#import "IAErrorHandler.h"

@implementation AppDelegate

@synthesize window, delay, startAtLogin, isSyncing;

dispatch_queue_t update_queue;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSUserDefaults * defaultPrefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * prefs = [[NSMutableDictionary alloc] init];
    
    ///////// Later will add more server options ////////////
    //NSMutableArray * servers = [NSMutableArray arrayWithObject:@"nasn1ac.cc.emory.edu/ecas-research"];
    //[prefs setValue:servers forKey:@"SERVER"];
    
    [prefs setValue:@"nasn1ac.cc.emory.edu/ecas-research" forKey:@"CURR_SERV"];
    [prefs setValue:@"" forKey:@"DEST"];
    [prefs setValue:@"" forKey:@"USERNAME"];
    [prefs setValue:[NSNumber numberWithLong:WEEKLY] forKey:@"SYNC_FREQ"];
    [prefs setValue:@"~/Desktop/" forKey:@"SOURCE"];
    [prefs setValue:[NSDate date] forKey:@"LAST_SYNC"];
    
    [defaultPrefs registerDefaults:prefs];
    
    delay = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(callEveryMinute) userInfo:nil repeats: YES];
    
}

- (void)callEveryMinute {
    
    //NSLog(@"called");
    
    IATimer * timer = [[IATimer alloc] init];
    if ([timer compareTime]) {
        [self syncSelected:@"timed"];
    }

}

- (void)awakeFromNib {

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSBundle * bundle = [NSBundle mainBundle];
    
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusSelected = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_selected" ofType:@"png"]];
    downIcon = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_syncing" ofType:@"png"]];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusSelected];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];

}

- (IBAction)savePressed:(id)sender {
    
    NSLog(@"Save pressed");
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    /* ///////// Later will add more server options ////////////
    NSMutableArray * servers = [prefs objectForKey:@"SERVER"];
    if ([self checkServerList:servers ForServer:[[serverChoice selectedItem] title]]) {
        [servers addObject:[[serverChoice selectedItem] title]];
    }
    [prefs setValue:servers forKey:@"SERVER"];
    [prefs setValue:[[serverChoice selectedItem] title] forKey:@"CURR_SERV"];
    */
    
    [prefs setValue:[self cleanDestinationPathForString:[destField stringValue]] forKey:@"DEST"];
    [prefs setValue:[usernameField stringValue] forKey:@"USERNAME"];
    [prefs setValue:[sourceField stringValue] forKey:@"SOURCE"];
    [prefs setValue:[NSNumber numberWithLong:[syncFreq indexOfSelectedItem] ] forKey:@"SYNC_FREQ"];
    
    IAKeyChainWrapper * keychain =[[IAKeyChainWrapper alloc] init];
    BOOL added = [keychain addToKeyChainPassword:[passwordField stringValue] AndUsername:[usernameField stringValue]];
    if (!added) {
        NSLog(@"Problems with Password Saving. Trying to modify.");
        added = [keychain changePasswordInKeyChain:[passwordField stringValue] ForUsername:[usernameField stringValue]];
        if(added) {
            NSLog(@"Successfully modified");
            [optionWindow close];
        }
        //Need user available error checking
    }

}

- (IBAction)optionsSelected:(id)sender {

    [NSApp activateIgnoringOtherApps:YES];
    NSLog(@"Options pressed");
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
   
    /* ///////// Later will add more server options ////////////
    NSMutableArray * servers = [prefs objectForKey:@"SERVER"];
    [serverChoice addItemsWithTitles:servers];
    [serverChoice selectItemWithTitle:@"CURR_SERV"];
    */
    
    [destField setStringValue:[prefs valueForKey:@"DEST"]];
    [usernameField setStringValue:[prefs valueForKey:@"USERNAME"]];
    [sourceField setStringValue:[prefs valueForKey:@"SOURCE"]];
    [syncFreq selectItemAtIndex:[[prefs valueForKey:@"SYNC_FREQ"] longValue]];
    
    NSString * password;
    if ([[prefs valueForKey:@"USERNAME"] length] != 0) {
        IAKeyChainWrapper * keychain =[[IAKeyChainWrapper alloc] init];
        password = [keychain fetchPasswordFromKeyChainWithUsername:[prefs valueForKey:@"USERNAME"] AndReference:nil];
        [passwordField setStringValue:password];
    } 
    
    [optionWindow setIsVisible:YES];
    [optionWindow setReleasedWhenClosed:FALSE];

}


- (IBAction)syncSelected:(id)sender {
    
    [NSApp activateIgnoringOtherApps:YES];
    NSLog(@"Sync pressed");
    
    if([self isSyncing]) { return; }
    else { [self setIsSyncing:YES]; }
    

    if (![IAReachability isInternetReachableByHost:@"google.com"]) {
        NSLog(@"No Internet.");
        
        NSAlert * alert = [[NSAlert alloc] init];
        
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"You don't seem to have an Internet connection."];
        [alert setInformativeText:@"Check your Network Settings."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
     
        [self setIsSyncing:NO];
        return;
    }
    
    [statusItem setImage:downIcon];
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    NSString * username = [prefs valueForKey:@"USERNAME"];
    
    if ([username length] == 0) {
        NSAlert * alert = [[NSAlert alloc] init];
        
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"There is an error with your username or password."];
        [alert setInformativeText:@"Check your options."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
        
        [self setIsSyncing:NO];
        return;
    }
    
    IAKeyChainWrapper * keychain =[[IAKeyChainWrapper alloc] init];
    NSString * passwd = [keychain fetchPasswordFromKeyChainWithUsername:username AndReference:nil];
    
    if ([passwd length] == 0) {
        
        NSAlert * alert = [[NSAlert alloc] init];
        
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"There is an error with your username or password."];
        [alert setInformativeText:@"Check your options."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
        
        [self setIsSyncing:NO];
        return;
    }
    
    update_queue = dispatch_queue_create("com.soma.labbackup.sync", NULL);
    
    dispatch_async(update_queue, ^{
        
        NSString * tmpPath = NSTemporaryDirectory();
        tmpPath = [tmpPath stringByAppendingPathComponent:@"back_up/"];
        
        int status = system([[NSString stringWithFormat:@"mkdir %@", tmpPath] cStringUsingEncoding:NSASCIIStringEncoding]);
        
        if(status == 0) {
            NSLog(@"Successful dir creation");
        } else { NSLog(@"mkdir error: %s" , strerror(errno)); }
    
        /****************
         *  Mount Call  *
         ****************/
        NSMutableArray * argsM = [[NSMutableArray alloc] init];
        [argsM addObject:@"-t"];
        [argsM addObject:@"smbfs"];
        NSString * remoteArg = [NSString stringWithFormat:@"//%@:%@@%@" , username , passwd , [prefs valueForKey:@"CURR_SERV"]];
        [argsM addObject:remoteArg];
        [argsM addObject:tmpPath];
        
        IAMountWrapper * mount = [[IAMountWrapper alloc] initWithArgument:argsM];
        NSString * outputM = [mount startMountAndGetOutput];
        
        IAErrorHandler * mount_error = [[IAErrorHandler alloc] initWithOutput:outputM];
        int m_error = [mount_error respondToOutput:MOUNT_ERROR];
        if (m_error != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert * alert = [[NSAlert alloc] init];
                
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"There has been a mounting error."];
                [alert setInformativeText:@"Make sure you are connected to an Emory network."];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert runModal];
                
            });
            
            [self setIsSyncing:NO];
            return;
            
        }
        //****************//
        
        //***************************//
        //Start the RSYNC process: rsync -avz foo:src/bar /data/tmp
        NSMutableArray * argsR = [[NSMutableArray alloc] init];
        [argsR addObject:@"-avz"];
        [argsR addObject:[prefs valueForKey:@"SOURCE"]];
        NSString * dest = [NSString stringWithFormat:@"%@/%@" , tmpPath , [prefs valueForKey:@"DEST"]];
        [argsR addObject:dest];
        
        IARSYNCWrapper * rsync = [[IARSYNCWrapper alloc] initWithArgument:argsR];
        NSString * outputR = [rsync startRSYNCAndGetOutput];
        
        IAErrorHandler * rsync_error = [[IAErrorHandler alloc] initWithOutput:outputR];
        int r_error = [rsync_error respondToOutput:RSYNC_ERROR];
        if (r_error != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert * alert = [[NSAlert alloc] init];
                
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"There has been a syncing error."];
                [alert setInformativeText:@"Check your options. You may not have the right destination folder."];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert runModal];
                
            });
            
            [self setIsSyncing:NO];
            return;
        }
        //***************************//
        
        /****************
         * Unmount Call *
         ****************/
        NSMutableArray * argsU = [[NSMutableArray alloc] init];
        //NSString * serverArg = [NSString stringWithFormat:@"//%@@nasn1ac.cc.emory.edu/ecas-research" , username];
        NSString * serverArg = [NSString stringWithFormat:@"//%@@%@" , username , [prefs valueForKey:@"CURR_SERV"]];
        [argsU addObject:serverArg];
        
        IAMountWrapper * umount = [[IAMountWrapper alloc] initWithArgument:argsU];
        NSString * outputU = [umount startUmountAndGetOutput];
        
        IAErrorHandler * umount_error = [[IAErrorHandler alloc] initWithOutput:outputU];
        int u_error = [umount_error respondToOutput:UMOUNT_ERROR];
        if (u_error != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert * alert = [[NSAlert alloc] init];
                
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"There has been an unmounting error."];
                [alert setInformativeText:@"Check your options."];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert runModal];
                
            });
            
            [self setIsSyncing:NO];
            return;
            
        }
        //****************//
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if ([sender isEqual:@"timed"]) {
                [prefs setValue:[NSDate date] forKey:@"LAST_SYNC"];
            }
            
            [self setIsSyncing:NO];
            [statusItem setImage:statusImage];
            
            NSAlert * alert = [[NSAlert alloc] init];
            
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Done."];
            [alert setInformativeText:@""];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
        
        });
        
    });
    
    
}

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)startAtLogin
{
    return [IALoginHandler willStartAtLogin:[self appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [IALoginHandler setStartAtLogin:[self appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}

- (NSString *) cleanDestinationPathForString:(NSString *)path {

    NSString * dest = path;
    if ([dest characterAtIndex:0] == '/') {
        dest = [dest substringFromIndex:1];
    }
    if ([dest characterAtIndex:[dest length]-1] != '/') {
        dest = [dest stringByAppendingString:@"/"];
    }
    
    return dest;

}


@end
