//
//  IAErrorHandler.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MOUNT_ERROR  0
#define RSYNC_ERROR  1
#define UMOUNT_ERROR 2

@interface IAErrorHandler : NSObject {

    NSString * outputFromCommand;

}

- (IAErrorHandler *) initWithOutput:(NSString *)output;
- (int) respondToOutput:(int)error;

@end
