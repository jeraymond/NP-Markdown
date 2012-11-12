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

@implementation NPMWindowController {
    NPMViewController *currentViewController;

    enum ViewType {
        EDITOR,
        SPLIT,
        PREVIEW
    };

    enum FileMode {
        EDIT,
        WATCH
    };
}

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
        [self activateViewForType:viewType];
    }
}

- (IBAction)viewSelectionDidChangeViaMenuToEditor:(id)sender
{
    [self activateViewForType:EDITOR];
}

- (IBAction)viewSelectionDidChangeViaMenuToSplit:(id)sender
{
    [self activateViewForType:SPLIT];
}

- (IBAction)viewSelectionDidChangeViaMenuToPreview:(id)sender
{
    [self activateViewForType:PREVIEW];
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

/**
  Gets the file mode string from the file mode type.
  @param fileMode the file mode, one of enum FileMode
  @return the file mode string or nil if the file mode is invalid
 */
+ (NSString *)fileModeStringFromFileMode:(NSInteger)fileMode
{
    NSString *string = nil;

    switch (fileMode) {
        case EDIT:
            string = @"Edit";
            break;
        case WATCH:
            string = @"Watch";
            break;
        default:
            DDLogError(@"%@", [NSString stringWithFormat:@"Unrecognized file mode %ld", fileMode]);
            break;
    }
    return string;
}

/**
  Gets the view name from a view type.
  @param viewType the view type, one of enum ViewType
  @return the view name or nil if the view type is invalid
 */
+ (NSString *)viewNameFromViewType:(NSInteger)viewType
{
    NSString *string = nil;

    switch (viewType) {
        case EDITOR:
            string = @"NPMEditorView";
            break;
        case SPLIT:
            string = @"NPMSplitView";
            break;
        case PREVIEW:
            string = @"NPMPreviewView";
            break;
        default:
            DDLogError(@"%@", [NSString stringWithFormat:@"Unrecognized view type %ld", viewType]);
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

/**
  Activates the view for the given view type. Sets control properties in the view as appropriate.
  @param viewType the view type, one of enum ViewType
 */
- (void)activateViewForType:(NSInteger)viewType
{
    [self.viewSegmentedControl setSelectedSegment:viewType];
    NSString *viewName = [NPMWindowController viewNameFromViewType:viewType];
    NPMViewController *newViewController = [self viewControllerForViewName:viewName];
    [self activateViewController:newViewController];
    DDLogInfo(@"View selection changed to %@", viewName);
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
    [self.bottomBorderTextField setStringValue:@"NP Markdown"];
}

@end
