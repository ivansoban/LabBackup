//
//  IAMountWrapper.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAMountWrapper : NSObject {
    
    NSTask       * mountTask;
    NSPipe       * pipeFromMountTask;
    NSFileHandle * readEndOfPipe;
    
}

- (IAMountWrapper *) initWithArgument:(NSArray *)args;
- (NSString *) startMountAndGetOutput;
- (NSString *) startUmountAndGetOutput;

@end
