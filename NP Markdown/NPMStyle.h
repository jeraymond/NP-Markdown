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

#import <Foundation/Foundation.h>

/**
  Tracks preview style information.
 */
@interface NPMStyle : NSObject

/**
  The list of available styles.
 */
@property (strong) NSArray *styleNames;

/**
  The currently selected style.
 */
@property (strong) NSString *selectedStyle;

/**
  The default style.
 */
@property (readonly) NSString *defaultStyle;

/**
  The template root directory of the currently selected style.
 */
@property (readonly) NSURL *selectedStyleTemplateRoot;

/**
  Applies the named style to the given HTML.
  The incoming HTML should be an html fragment.
  This method will supply the html, body, head, etc HTML elements.
  @param style one of the supported styles as defined by the styleNames property
  @param html the html block to stylize
  @return the stylized html
 */
- (NSString *)applyStyle:(NSString *)style toHtml:(NSString *)html;

@end
