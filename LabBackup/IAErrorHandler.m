//
//  IAErrorHandler.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IAErrorHandler.h"

@implementation IAErrorHandler

- (IAErrorHandler *) initWithOutput:(NSString *)output {

    self = [super init];
    
    if (self) {
    
        outputFromCommand = output;
    
    }
    
    return self;

}

- (int) respondToOutput:(int)error {

    NSString * lOutput = outputFromCommand;
    
    switch (error) {
        case MOUNT_ERROR:
            //Check error
            if ([lOutput length] == 0) { 
                return 0;                              // No error.
            } else {
                NSLog(@"MOUNT ERROR: %@" , lOutput);
                return 1;                              // Mount error.
            }
            break;
            
        case RSYNC_ERROR:
            //Check error
            if ([lOutput isEqualToString:@"NODIR"]) {
                NSLog(@"RSYNC ERROR: %@" , lOutput);
                return 2;                              // The folder doesn't exist.
            } else {
                return 0;
            }
            break;
            
        case UMOUNT_ERROR:
            //Check error
            if ([lOutput length] == 0) {
                return 0;                              // No error.
            } else {
                NSLog(@"UMOUNT ERROR: %@" , lOutput);
                return 3;                              // Umount error.
            }
            break;
            
        default:
            break;
    }
    
    return 0;

}

@end
