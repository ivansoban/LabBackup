//
//  IARSYNCWrapper.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/16/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IARSYNCWrapper : NSObject {

    NSTask       * rsync;
    NSPipe       * pipeFromRSYNC;
    NSFileHandle * readEndOfPipe;
    
    NSArray      * arguments;

}

- (IARSYNCWrapper *) initWithArgument:(NSArray *)args;
- (NSString *) startRSYNCAndGetOutput;

@end
