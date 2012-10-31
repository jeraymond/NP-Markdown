//
//  NPMWindowController.m
//  NP Markdown
//
//  Created by Jeremy Raymond on 2012-10-31.
//  Copyright (c) 2012 Jeremy Raymond. All rights reserved.
//

#import "NPMWindowController.h"

@interface NPMWindowController ()

@end

@implementation NPMWindowController

@synthesize bottomBorderTextField;

#pragma mark NSWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"NPMDocument"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateBottomBorderText];
}

#pragma mark Internal

- (void)updateBottomBorderText
{
    [bottomBorderTextField setStringValue:@"NP Markdown"];
}

@end
