//
//  IALoginHandler.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/18/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@interface IALoginHandler : NSObject

+ (BOOL) willStartAtLogin:(NSURL *)itemURL;
+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end
