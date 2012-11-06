/*******************************************************************************
 * Copyright 2012 Jeremy Raymond
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/

#import "NPMLog.h"
#import "NPMWindowController.h"
#import "NPMViewController.h"

@interface NPMWindowController ()
{
    NPMViewController *currentViewController;
}

@end

@implementation NPMWindowController

@synthesize data;
@synthesize renderer;

@synthesize viewSegmentedControl;
@synthesize fileModeSegmentedControl;
@synthesize bottomBorderTextField;

@synthesize viewControllers;

#pragma mark NSWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"NPMDocument"];
    if (self) {
        self.viewControllers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateBottomBorderText];
    NPMViewController *initialViewController = [self viewControllerForViewName:@"NPMSplitView"];
    [self activateViewController:initialViewController];
}

#pragma mark Selectors

- (IBAction)viewSelectionDidChange:(id)sender
{
    if (sender == self.viewSegmentedControl) {
        NSInteger viewType = [sender selectedSegment];
        NSString *viewName = [NPMWindowController viewNameFromViewType:viewType];
        NPMViewController *newViewController = [self viewControllerForViewName:viewName];
        [self activateViewController:newViewController];
        DDLogInfo(@"View selection changed to %@", viewName);
    }
}

- (IBAction)fileModeSelectionDidChange:(id)sender
{
    if (sender == self.fileModeSegmentedControl) {
        NSInteger fileMode = [sender selectedSegment];
        NSString *fileModeString = [NPMWindowController fileModeStringFromFileMode:fileMode];
        DDLogInfo(@"File mode selection changed to %@", fileModeString);
    }
}

#pragma mark Internal

+ (NSString *)fileModeStringFromFileMode:(NSInteger)fileMode
{
    NSString *string;

    switch (fileMode) {
        case 0:
            string = @"Edit";
            break;
        case 1:
            string = @"Watch";
            break;
        default:
            string = [NSString stringWithFormat:@"Unrecognized file mode %ld", fileMode];
            DDLogError(@"%@", string);
            break;
    }
    return string;
}

+ (NSString *)viewNameFromViewType:(NSInteger)viewType
{
    NSString *string;

    switch (viewType) {
        case 0:
            string = @"NPMEditorView";
            break;
        case 1:
            string = @"NPMSplitView";
            break;
        case 2:
            string = @"NPMPreviewView";
            break;
        default:
            string = [NSString stringWithFormat:@"Unrecognized view type %ld", viewType];
            DDLogError(@"%@", string);
            break;
    }
    return string;
}

- (NPMViewController *)viewControllerForViewName:(NSString *)viewName
{
    NPMViewController *controller = [self.viewControllers objectForKey:viewName];
    if (controller) {
        return controller;
    }
    controller = [[NPMViewController alloc] initWithNibName:viewName bundle:nil];
    [self.viewControllers setObject:controller forKey:viewName];
    controller.data = self.data;
    controller.renderer = self.renderer;
    return controller;
}

- (void)activateViewController:(NPMViewController *)viewController
{
    // Set view size
    NSView *view = viewController.view;
    NSWindow *window = self.window;
    CGFloat padding = [window contentBorderThicknessForEdge:NSMinYEdge];
    NSRect frame = [window.contentView frame];
    frame.size.height -= padding;
    frame.origin.y += padding;
    view.frame = frame;
    view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    
    // Add view to content view
    if (currentViewController != nil) {
        [currentViewController.view removeFromSuperview];
    }
    currentViewController = viewController;
    [[self.window contentView] addSubview:view];
    [viewController viewDidAppear];
}

- (void)updateBottomBorderText
{
    // TODO: display file URL (if there is one)
    [bottomBorderTextField setStringValue:@"NP Markdown"];
}

@end
