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
#import "NPMStyle.h"

@implementation NPMViewController {
    WebView *_previewWebView;
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
    [self setupNotifications];
}

- (void)viewDidDisappear
{
    [self teardownNotifications];
}

#pragma mark Notifications

- (void)setupNotifications
{
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:) name:NPMNotificationRenderComplete object:self.renderer];
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:) name:NPMNotificationStyleChanged object:self.style];
}

- (void)teardownNotifications
{
    [NPMNotificationQueue removeObserver:self name:NPMNotificationRenderComplete object:self.renderer];
    [NPMNotificationQueue removeObserver:self name:NPMNotificationStyleChanged object:self.style];
}

#pragma mark Editor

- (void)initializeEditorTextView
{
    [self updateTextViewFromData];
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

- (void)updateTextViewFromData
{
    if (self.editorTextView) {
        NSString *text = [[self data] text];
        if (!text) {
            text = @"";
        }
        [self.editorTextView setString:text];
    }
}

#pragma mark Preview

- (void)initializePreviewWebView
{
    if (self.previewView && !_previewWebView) {
        NSRect frame = [self.previewView frame];
        _previewWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        [_previewWebView setUIDelegate:self];
        [_previewWebView setFrameLoadDelegate:self];
        [_previewWebView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    }
    if (self.previewView && _previewWebView) {
        [self.previewView addSubview:_previewWebView];
        [self updatePreview];
    }
}

- (void)updatePreview
{
    if (_previewWebView) {
        NSString *renderedHtml = self.renderer.html;
        NSString *currentStyle = self.style.selectedStyle;
        NSString *styledHtml = [self.style applyStyle:currentStyle toHtml:renderedHtml];
        [[_previewWebView mainFrame] loadHTMLString:styledHtml baseURL:self.style.selectedStyleTemplateRoot];
    }
}

- (void)updatePreviewFromNotification:(NSNotification *)notification
{
    [self updatePreview];
}

@end
