//
//  IAReachability.h
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/18/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAReachability : NSObject

+ (BOOL) isInternetReachableByHost:(NSString *)url;

@end
