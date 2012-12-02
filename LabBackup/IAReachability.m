//
//  IAReachability.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/18/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IAReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation IAReachability

+ (BOOL) isInternetReachableByHost:(NSString *)url {

    const char *hostName = [url cStringUsingEncoding:NSASCIIStringEncoding];
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithName(NULL, hostName);
    SCNetworkConnectionFlags flags = 0;
    SCNetworkReachabilityGetFlags(target, &flags);
    CFRelease(target);
    
    
    Boolean ok;
    if ((flags & kSCNetworkFlagsReachable)
        && !(flags & kSCNetworkFlagsConnectionRequired)) {
        ok = true;
    } else {
        ok = false;
    }
    
    return (BOOL)ok;
}

@end
