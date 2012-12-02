//
//  IASourceTextField.m
//  LabBackup
//
//  Created by Ivan Antolic-Soban on 11/17/12.
//  Copyright (c) 2012 Ivan Antolic-Soban. All rights reserved.
//

#import "IASourceTextField.h"
#import "AppDelegate.h"

@implementation IASourceTextField

-(void)mouseDown:(NSEvent*) theEvent {

    NSOpenPanel * selectDir = [NSOpenPanel openPanel];
    [selectDir setCanChooseDirectories:YES];
    [selectDir setCanChooseFiles:NO];
    [selectDir setAllowsMultipleSelection:NO];
    
    if ( [selectDir runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray
        *files = [selectDir URLs];
        
        NSURL * fileURL = [files objectAtIndex:0];
        NSString * filePath = [fileURL path];
        
        [self setStringValue:filePath];
        
    }
    
    
}

@end
