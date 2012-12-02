//
//  IAKeyChainWrapper.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>
#import <CoreServices/CoreServices.h>
#import <EventKit/EventKit.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface IAKeyChainWrapper : NSObject

- (BOOL) addToKeyChainPassword:(NSString *)password AndUsername:(NSString *)username;
- (NSString *) fetchPasswordFromKeyChainWithUsername:(NSString *)username AndReference:(SecKeychainItemRef *)ref;
- (BOOL) changePasswordInKeyChain:(NSString *)password ForUsername:(NSString *)username;

@end
