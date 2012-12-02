//
//  IAMountWrapper.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IAMountWrapper.h"

@implementation IAMountWrapper

- (IAMountWrapper *) initWithArgument:(NSArray *)args {
    
    self = [super init];
    
    if(self) {
    
        mountTask         = [[NSTask alloc] init];
        pipeFromMountTask = [[NSPipe alloc] init];
        readEndOfPipe = [pipeFromMountTask fileHandleForReading];
        
        [mountTask setArguments:args];
        
        [mountTask setStandardOutput:pipeFromMountTask];
        [mountTask setStandardError:pipeFromMountTask];
        
        [mountTask setCurrentDirectoryPath:@"/"];
    
    }
    
    return self;

}

- (NSString *) startMountAndGetOutput {

    [mountTask setLaunchPath:@"/sbin/mount"];
    [mountTask launch];
    
    [mountTask waitUntilExit];
    
    NSData   * stdoutData = [readEndOfPipe availableData];
    NSString * readOut = [[NSString alloc] initWithData:stdoutData encoding:NSASCIIStringEncoding];
    return readOut;
    
}

- (NSString *) startUmountAndGetOutput {

    [mountTask setLaunchPath:@"/sbin/umount"];
    [mountTask launch];
    
    [mountTask waitUntilExit];
    
    NSData   * stdoutData = [readEndOfPipe availableData];
    NSString * readOut = [[NSString alloc] initWithData:stdoutData encoding:NSASCIIStringEncoding];
    return readOut;

}

@end
