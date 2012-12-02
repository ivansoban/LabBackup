//
//  IARSYNCWrapper.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/16/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IARSYNCWrapper.h"

@implementation IARSYNCWrapper


- (IARSYNCWrapper *) initWithArgument:(NSArray *)args {

    self = [super init];
    
    if (self) {
        
        rsync         = [[NSTask alloc] init];
        pipeFromRSYNC = [[NSPipe alloc] init];
        readEndOfPipe = [pipeFromRSYNC fileHandleForReading];
        arguments = args; // 0 = -avz, 1 = source, 2 = dest //
        
        [rsync setLaunchPath:@"/usr/bin/rsync"];
        
        [rsync setArguments:args];
        
        [rsync setStandardOutput:pipeFromRSYNC];
        [rsync setStandardError:pipeFromRSYNC];
        
    }
    
    return self;

}

- (NSString *) startRSYNCAndGetOutput {
    
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:[arguments objectAtIndex:2] isDirectory:&isDirectory];
    
    if (exists && isDirectory) {
        
        [rsync launch];
        [rsync waitUntilExit];
        
        NSData   * stdoutData = [readEndOfPipe availableData];
        NSString * readOut = [[NSString alloc] initWithData:stdoutData encoding:NSASCIIStringEncoding];
        return readOut;
        
    } else { return @"NODIR"; }
    
    
    
}

@end
