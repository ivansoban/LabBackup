//
//  IAKeyChainWrapper.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IAKeyChainWrapper.h"

@implementation IAKeyChainWrapper

- (BOOL) addToKeyChainPassword:(NSString *)password AndUsername:(NSString *)username {

    const char * passwd = [password cStringUsingEncoding:NSASCIIStringEncoding];
    const char * uname  = [username cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 passwordLength = (UInt32)strlen(passwd);
    UInt32 accountLength  = (UInt32)strlen(uname);
        
    OSStatus status;
        
    status = SecKeychainAddGenericPassword (
            NULL,           // default keychain
            9,              // length of service name
            "LabBackup",    // service name
            accountLength,  // length of account name
            uname,          // account name
            passwordLength, // length of password
            passwd,         // pointer to password data
            NULL            // the item reference
    );
        
    if(status == noErr) return YES;
    else return NO;

}

- (NSString *) fetchPasswordFromKeyChainWithUsername:(NSString *)username AndReference:(SecKeychainItemRef *)ref {
    
    void * passwordData = nil;
    UInt32 passwordLength;
    
    const char * uname = [username cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 usernameLength = (UInt32)strlen(uname);
        
    OSStatus status;
        
    status = SecKeychainFindGenericPassword (
            NULL,           // default keychain
            9,              // length of service name
            "LabBackup",    // service name
            usernameLength, // length of account name
            uname,          // account name
            &passwordLength, // length of password       UInt32 *passwordLength,
            &passwordData,  // pointer to password data  void **passwordData,
            ref             // the item reference        SecKeychainItemRef *itemRef
    );
    
    /*
     OSStatus SecKeychainFindGenericPassword (
        CFTypeRef keychainOrArray,
        UInt32 serviceNameLength,
        const char *serviceName,
        UInt32 accountNameLength,
        const char *accountName,
        UInt32 *passwordLength,
        void **passwordData,
        SecKeychainItemRef *itemRef
     );
     */
    
    if (status == noErr) {
        
        NSString * pass = [NSString stringWithCString:(const char *)passwordData encoding:NSASCIIStringEncoding];
        pass = [pass substringToIndex:passwordLength];
        
        status = SecKeychainItemFreeContent (
            NULL,           //No attribute data to release
            passwordData    //Release data buffer allocated by SecKeychainFindGenericPassword
        );
        
        return pass;
    } else {
        NSLog(@"%s" , strerror(noErr));
        return NULL;
    }

}

- (BOOL) changePasswordInKeyChain:(NSString *)password ForUsername:(NSString *)username {
    
    SecKeychainItemRef ref = nil;
    
    [self fetchPasswordFromKeyChainWithUsername:username AndReference:&ref];

    void * passwd = (void *)[password cStringUsingEncoding:NSASCIIStringEncoding];
    UInt32 passwordLength = (UInt32)strlen(passwd);
        
    OSStatus status;
        
    status = SecKeychainItemModifyAttributesAndData (
            ref,             // the item reference
            NULL,            // no change to attributes
            passwordLength,  // length of password
            passwd           // pointer to password data
    );
      
    if(status == noErr) return YES;
    else return NO;

}

@end
