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

@class NPMData;

/**
  The Markdown renderer.
  The renderer registers for NPMNotificationDataChanged notifications.
  When these notifications are recieved the Markdown contained in the NPMData object is rendered.
  When rendering completes an NPMNotificationRenderComplete notification is fired with the notification object set to the renderer instance.
  The rendered HTML is then available via the html property.
 */
@interface NPMRenderer : NSObject

/**
  The model data.
 */
@property (strong) NPMData *data;

/**
  The most recently rendered data.
 */
@property (readonly) NSString *html;

/**
  Initialize the renderer with the given data.
  @param data the data
  @return the renderer or nil
 */
- (id)initWithData:(NPMData *)data;

@end
