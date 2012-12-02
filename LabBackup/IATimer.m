//
//  IATimer.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/16/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IATimer.h"
#import "AppDelegate.h"

@implementation IATimer

- (BOOL) compareTime {
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    long option = [[prefs valueForKey:@"SYNC_FREQ"] longValue];
    
    NSDate * now = [NSDate date];
    
    NSDate * lastSync = [prefs valueForKey:@"LAST_SYNC"];
    
    switch (option) {
        case WEEKLY:
            if ([now timeIntervalSinceDate:lastSync] > 604799.99) {
                return YES;
            }
            break;
        
        case DAILY:
            if ([now timeIntervalSinceDate:lastSync] > 86400.00) {
                return YES;
            }
            break;
            
        case HOURLY:
            if ([now timeIntervalSinceDate:lastSync] > 3600.00) {
                return YES;
            }
            break;
            
        default:
            break;
            
    }
    
    
    return NO;

}

@end
