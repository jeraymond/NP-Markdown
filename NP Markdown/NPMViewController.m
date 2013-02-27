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
#import "NPMWindowController.h"
#import "NPMData.h"
#import "NPMRenderer.h"
#import "NPMNotificationQueue.h"
#import "NPMStyle.h"
#import "NPMLog.h"

NSString * const NPMPrevewHtmlScrollAnchor = @"<a name='NP Markdown scroll-to placeholder'></a>";
NSString * const NPMPreviewHtmlScrollJavaScript = @"window.location.hash='NP Markdown scroll-to placeholder';";

@implementation NPMViewController {
    WebView *_previewWebView;
    NSString *_currentPreviewHtml;
    NSImageView *_previewImageView;
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
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:)
                                 name:NPMNotificationRenderComplete object:self.renderer];
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:)
                                 name:NPMNotificationStyleChanged object:self.style];
    [NPMNotificationQueue addObserver:self selector:@selector(updatePreviewFromNotification:)
                                 name:NPMNotificationViewSelectionChanged object:self.windowController];
}

- (void)teardownNotifications
{
    [NPMNotificationQueue removeObserver:self name:NPMNotificationRenderComplete object:self.renderer];
    [NPMNotificationQueue removeObserver:self name:NPMNotificationStyleChanged object:self.style];
    [NPMNotificationQueue removeObserver:self name:NPMNotificationViewSelectionChanged object:self.windowController];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDataFromTextView) object:nil];
    [self performSelector:@selector(updateDataFromTextView) withObject:nil afterDelay:0.25];
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
    if (_previewWebView) {
        [_previewWebView removeFromSuperview];
        _previewWebView = nil;
    }
    if (_previewView && !_previewWebView) {
        NSRect frame = [self.previewView frame];
        _previewWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        [_previewWebView setUIDelegate:self];
        [_previewWebView setFrameLoadDelegate:self];
        [_previewWebView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [self.previewView addSubview:_previewWebView];
    }
}


- (void)updatePreview
{
     // Some of the preview update actions take place in this method.
     // The rest occur once the web view has finished loading in webView:didFinishLoadForFrame:
    DDLogInfo(@"Updating preview");
    if (_previewWebView) {
        // Get styled HTML
        NSString *renderedHtml = self.renderer.html;
        NSString *currentStyle = self.style.selectedStyle;
        NSString *styledHtml = [self.style applyStyle:currentStyle toHtml:renderedHtml];

        // Determine scroll position and insert the scroll anchor.
        // The scrolling is triggered when the webView:didFinishLoadForFrame
        NSString *previousHtml = _currentPreviewHtml;
        _currentPreviewHtml = styledHtml;
        styledHtml = [self stringByInsertingString:NPMPrevewHtmlScrollAnchor
                                        intoString:styledHtml
                   atFirstLineMismatchAsComparedTo:previousHtml];

        // Swap web view for image view - smooths transition between renders
        if ([_previewWebView superview] == _previewView) {
            _previewImageView = [self imageViewFromWebView:_previewWebView];
            [[_previewView animator] replaceSubview:_previewWebView with:_previewImageView];
        }

        // Set the conent
        [[_previewWebView mainFrame] loadHTMLString:styledHtml baseURL:self.style.selectedStyleTemplateRoot];
    }
}

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    if (_previewWebView) {
        // Perform scroll
        [[_previewWebView windowScriptObject] evaluateWebScript:NPMPreviewHtmlScrollJavaScript];
    }

    // Restore web view
    if ([_previewImageView superview] == _previewView) {
        [[_previewView animator] replaceSubview:_previewImageView with:_previewWebView];
    }
}

- (NSImageView *)imageViewFromWebView:(WebView *)webView
{
    NSBitmapImageRep *imageRep = [webView bitmapImageRepForCachingDisplayInRect:[webView frame]];
    [webView cacheDisplayInRect:[webView frame] toBitmapImageRep:imageRep];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:[webView frame]];
    NSImage *image = [[NSImage alloc] initWithSize:[webView frame].size];
    [image addRepresentation:imageRep];
    [imageView setImage:image];
    return imageView;
}

- (NSString *)stringByInsertingString:(NSString *)marker intoString:(NSString *)target
      atFirstLineMismatchAsComparedTo:(NSString *)other
{
    if (target == nil || target.length == 0 || other == nil || other.length == 0) {
        return target;
    }

    NSString *result = target;

    NSUInteger targetIndex = 0;
    NSUInteger targetLength = [target length];

    NSUInteger otherIndex = 0;
    NSUInteger otherLength = [other length];

    NSRange targetLineRange;
    NSString *targetLine;

    NSRange otherLineRange;
    NSString *otherLine;

    BOOL insertMade = NO;

    while (targetIndex < targetLength && otherIndex < otherLength) {
        targetLineRange = [target lineRangeForRange:NSMakeRange(targetIndex, 0)];
        targetLine = [target substringWithRange:targetLineRange];

        otherLineRange = [other lineRangeForRange:NSMakeRange(otherIndex, 0)];
        otherLine = [other substringWithRange:otherLineRange];

        targetIndex = NSMaxRange(targetLineRange);
        otherIndex = NSMaxRange(otherLineRange);

        if (![targetLine isEqualToString:otherLine]) {
            result = [result stringByReplacingCharactersInRange:NSMakeRange(targetIndex - [targetLine length], 0) withString:marker];
            insertMade = YES;
            break;
        }
    }
    if (!insertMade && targetLength != otherLength) { // insertion or deletion at end of text
        if (targetLength > otherLength) { // text inserted at end
            result = [result stringByReplacingCharactersInRange:NSMakeRange(targetIndex, 0) withString:marker];
        } else { // text deleted at end
            result = [result stringByAppendingString:marker];
        }
    }
    return result;
}

- (void)updatePreviewFromNotification:(NSNotification *)notification
{
    DDLogInfo(@"Updating preview from notif %@", [notification name]);
    [self updatePreview];
}

@end
