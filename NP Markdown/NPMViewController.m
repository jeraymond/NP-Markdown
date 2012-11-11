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

#import <WebKit/WebKit.h>
#import "NPMViewController.h"
#import "NPMData.h"
#import "NPMRenderer.h"
#import "NPMNotificationQueue.h"

@implementation NPMViewController {
    WebView *previewWebView;
}

#pragma mark NSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)viewDidAppear
{
    [self initializeEditorTextView];
    [self initializePreviewWebView];
}

#pragma mark Editor

- (void)initializeEditorTextView
{
    if (self.editorTextView) {
        [self.editorTextView setString:[self.data text]];
    }
}

/**
 * NSTextDelegate callback for Editor text view changes.
 * @param notification the notification
 */
- (void)textDidChange:(NSNotification *)notification
{
    [self updateDataFromTextView];
}

- (void)updateDataFromTextView
{
    NSString *newText = [[self.editorTextView textStorage] string];
    self.data.text = newText;
}

#pragma mark Preview

- (void)initializePreviewWebView
{
    if (self.previewView && !previewWebView) {
        NSRect frame = [self.previewView frame];
        previewWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        [previewWebView setUIDelegate:self];
        [previewWebView setFrameLoadDelegate:self];
        [previewWebView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [self.previewView addSubview:previewWebView];
    }
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:) name:NPMNotificationRenderComplete object:self.renderer];
    [self updatePreview];
}

- (void)updatePreview
{
    if (previewWebView) {
        NSString *previewHtmlContent = self.renderer.html;
        [[previewWebView mainFrame] loadHTMLString:previewHtmlContent baseURL:nil];
    }
}

- (void)updatePreviewFromNotification:(NSNotification *)notification
{
    [self updatePreview];
}

@end
