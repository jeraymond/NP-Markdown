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
#import "NPMData.h"
#import "NPMNotificationQueue.h"
#import "NPMDocument.h"
#import "NPMStyle.h"

@implementation NPMWindowController {
    NPMViewController *_currentViewController;
    NSInteger _previousViewType;

    enum FileMode _currentFileMode;

    enum ViewType {
        EDITOR,
        SPLIT,
        PREVIEW
    };
}

#pragma mark Init

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class NPMWindowController"
                                 userInfo:nil];
    return nil;
}

- (id)initWithData:(NPMData *)data andRenderer:(NPMRenderer *)renderer
{
    self = [super initWithWindowNibName:@"NPMDocument"];
    if (self) {
        self.viewControllers = [NSMutableDictionary dictionary];
        self.data = data;
        self.renderer = renderer;
        self.style = [[NPMStyle alloc] init];
        [NPMNotificationQueue addObserver:self selector:@selector(dataSaved:) name:NPMNotificationDataSaved
                                   object:self.data];
    }
    return self;
}

#pragma NSWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateFooterText];
    [self initializeStylePopUpButton];
    [self.fileModeSegmentedControl setSelectedSegment:EDIT];
    [self.viewSegmentedControl setSelectedSegment:SPLIT];
    [self activateViewForType:SPLIT];
    if (_currentViewController.editorTextView) {
        [self.window performSelector:@selector(makeFirstResponder:) withObject:_currentViewController.editorTextView
                          afterDelay:0.0];
    }
}

#pragma mark Style

- (void)initializeStylePopUpButton
{
    for (NSString *style in self.style.styleNames) {
        [self.stylePopUpButton addItemWithTitle:style];
    }
    [self.stylePopUpButton selectItemWithTitle:self.style.defaultStyle];
    self.style.selectedStyle = self.stylePopUpButton.selectedItem.title;
}

- (IBAction)styleDidChange:(id)sender
{
    self.style.selectedStyle = self.stylePopUpButton.selectedItem.title;
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
        switch (fileMode) {
            case EDIT:
                [self enableEditMode];
                break;
            case WATCH:
                [self enableWatchMode];
                break;
            default:
                DDLogError(@"Invalid file mode %ld", fileMode);
                break;
        }
    }
}

# pragma mark File Mode

- (void)enableEditMode
{
    if (_currentFileMode == EDIT) {
        return;
    }
    
    DDLogInfo(@"File mode changed to edit");
    _currentFileMode = EDIT;
    [self activateViewForType:_previousViewType];
    [self.viewSegmentedControl setEnabled:YES];
    [self updateFooterText];
    [NPMNotificationQueue enqueueNotificationWithName:NPMNotificationChangeFileModeToEdit object:self];
}

- (void)enableWatchMode
{
    if (_currentFileMode == WATCH) {
        return;
    }

    if ([[self document] isDocumentEdited] || !self.data.url) {
        [self askForSaveBeforeWatch];
        [self.fileModeSegmentedControl setSelectedSegment:EDIT];
        return;
    }

    DDLogInfo(@"File mode changed to watch");
    _currentFileMode = WATCH;
    _previousViewType = self.viewSegmentedControl.selectedSegment;
    [self.fileModeSegmentedControl setSelectedSegment:WATCH];
    [self activateViewForType:PREVIEW];
    [self.viewSegmentedControl setEnabled:NO];
    [self updateFooterText];
    [NPMNotificationQueue enqueueNotificationWithName:NPMNotificationChangeFileModeToWatch object:self];
}

- (void)askForSaveBeforeWatch
{
    NSString *question = @"Do you want to save the changes you made before watching the file for changes?";
    NSString *info = @"";

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:question];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    if (self.data.url) {
        [alert addButtonWithTitle:@"Don't Save"];
    }
    [alert beginSheetModalForWindow:self.window modalDelegate:self
                     didEndSelector:@selector(alertForSaveBeforeWatchDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) alertForSaveBeforeWatchDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [[alert window] orderOut:alert];
    if (returnCode == NSAlertFirstButtonReturn) {
        [[self document] saveDocumentWithDelegate:self didSaveSelector:@selector(documentForWatch:didSave:contextInfo:)
                                      contextInfo:NULL];
        DDLogInfo(@"Saving before watch");
    } else if (returnCode == NSAlertSecondButtonReturn) {
        DDLogInfo(@"Cancel watch");
    } else {
        NSError *error;
        if ([[self document] revertToContentsOfURL:self.data.url ofType:nil error:&error]) {
            DDLogInfo(@"Reverted document %@ for watching", self.data.url.path);
            [self enableWatchMode];
        } else {
            DDLogError(@"Error reverting file %@ for watching: %@", self.data.url.path, [error localizedDescription]);
            [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        }
    }
}

- (void)documentForWatch:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
    if (didSave == YES) {
        [self enableWatchMode];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    SEL action = item.action;
    if (_currentFileMode == WATCH &&
        (action == @selector(viewSelectionDidChangeViaMenuToEditor:) ||
         action == @selector(viewSelectionDidChangeViaMenuToSplit:) ||
         action == @selector(viewSelectionDidChangeViaMenuToPreview:))) {
        return NO;
    }
    return YES;
}

#pragma mark Notifications

- (void)dataSaved:(NSNotification *)notification
{
    [self updateFooterText];
}

#pragma mark Internal

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
    controller.style = self.style;
    return controller;
}

/**
  Activates the view for the given view type.
  Sets control properties in the view as appropriate.
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
    if (_currentViewController != nil) {
        [_currentViewController.view removeFromSuperview];
        [_currentViewController viewDidDisappear];
    }
    _currentViewController = viewController;
    [[self.window contentView] addSubview:view];
    [viewController viewDidAppear];
    if (viewController.editorTextView) {
        [self.window makeFirstResponder:viewController.editorTextView];
    }
}

- (void)updateFooterText
{
    NSString *footerText = @"NP Markdown";
    if (self.data.url) {
        if (_currentFileMode == EDIT) {
            footerText = @"Editing ";
        } else {
            footerText = @"Watching ";
        }
        footerText = [footerText stringByAppendingString:self.data.url.path];
    }
    [self.footerTextField setStringValue:footerText];
}

@end
