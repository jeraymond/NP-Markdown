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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class NPMData;
@class NPMRenderer;
@class NPMStyle;
@class NPMWindowController;
@class WebView;

/**
  The view controller for the Editor and Preview view.
 */
@interface NPMViewController : NSViewController<WebUIDelegate, WebFrameLoadDelegate>

/**
  The model data.
 */
@property (strong) NPMData *data;

/**
  The renderer.
 */
@property (strong) NPMRenderer *renderer;

/**
  The style.
 */
@property (strong) NPMStyle *style;

/**
  The editor text view.
 */
@property (strong) IBOutlet NSTextView *editorTextView;

/**
  The preview view. 
  The preview content is a subview of this view.
 */
@property (strong) IBOutlet NSView *previewView;

/**
  The parent window controller.
 */
@property (strong) NPMWindowController *windowController;

/**
  Notify the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear;

/**
  Notify the view controller that its view was removed from the view hierarchy.
 */
- (void)viewDidDisappear;

@end
