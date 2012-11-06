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

@interface NPMViewController () {
    WebView *previewWebView;
}

@end

@implementation NPMViewController

@synthesize data;
@synthesize renderer;

@synthesize editorTextView;
@synthesize previewView;

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
    [self initalizeEditorTextView];
    [self initializePreviewWebView];
}

#pragma mark Internal

- (void)initalizeEditorTextView
{
    if (editorTextView) {
        [editorTextView setString:[data text]];
    }
}

- (void)initializePreviewWebView
{
    if (previewView && !previewWebView) {
        NSRect frame = [previewView frame];
        previewWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        [previewWebView setUIDelegate:self];
        [previewWebView setFrameLoadDelegate:self];
        [previewWebView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [previewView addSubview:previewWebView];
    }
    if (previewWebView) {
        NSString *previewHtmlContent = renderer.html;
        [[previewWebView mainFrame] loadHTMLString:previewHtmlContent baseURL:nil];
    }
}

@end
