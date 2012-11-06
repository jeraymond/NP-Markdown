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

@class NPMData;
@class WebView;

/**
  The view controller for the Editor and Preview view.
 */
@interface NPMViewController : NSViewController

/**
  The model data.
 */
@property (strong) NPMData *data;

/**
  The editor text view.
 */
@property (strong) IBOutlet NSTextView *editorTextView;

/**
  The preview web view.
 */
@property (strong) IBOutlet WebView *previewWebView;

/**
  Notify the view controller that its view was added to a view hierarchy.

  Note that unlike the viewDidAppear method in the iOS UIViewController class
  this method is not called automatically in Cocoa. The window controller must
  call this method explicitly.
 */
- (void)viewDidAppear;

@end
