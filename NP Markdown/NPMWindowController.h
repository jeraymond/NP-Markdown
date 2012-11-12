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
@class NPMRenderer;
@class NPMViewController;

/**
  Window controller for Markdown documents.
 */
@interface NPMWindowController : NSWindowController

/**
  The model data.
 */
@property (strong) NPMData *data;

/**
 The renderer.
 */
@property (strong) NPMRenderer *renderer;

/**
  The view segmented control used to change the currently displayed view.
 */
@property (strong) IBOutlet NSSegmentedControl *viewSegmentedControl;

/**
  The file mode segmented control used to change the current file mode.
 */
@property (strong) IBOutlet NSSegmentedControl *fileModeSegmentedControl;

/**
  The display text field in the bottom border.
 */
@property (strong) IBOutlet NSTextField *bottomBorderTextField;

/**
  The view controllers for the main view.
 */
@property (strong) NSMutableDictionary *viewControllers;

/**
  Notify the window controller that the view selection has changed.
  @param sender the view segmented control
 */
- (IBAction)viewSelectionDidChange:(id)sender;

/**
  Notify the window controller that the view selection has changed to Editor via the menu.
  @param sender the menu item that changed the view
 */
- (IBAction)viewSelectionDidChangeViaMenuToEditor:(id)sender;

/**
 Notify the window controller that the view selection has changed to Split via the menu.
 @param sender the menu item that changed the view
 */
- (IBAction)viewSelectionDidChangeViaMenuToSplit:(id)sender;

/**
 Notify the window controller that the view selection has changed to Preview via the menu.
 @param sender the menu item that changed the view
 */
- (IBAction)viewSelectionDidChangeViaMenuToPreview:(id)sender;

/**
  Notify the window controller that the file mode selection has changed.
  @param sender the file mode segmented control
 */
- (IBAction)fileModeSelectionDidChange:(id)sender;

@end
