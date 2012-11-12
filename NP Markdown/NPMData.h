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
  The Markdown data model.
  <p>
  When the data text is changed via the text property an NPMNotificationDataChanged notification is fired with the notification object set to the data instance.
 */
@interface NPMData : NSObject

/**
  The Markdown syntax text.
 */
@property (strong) NSString *text;

/**
  The URL of the model data. 
  May be nil if the data has not been previously saved.
 */
@property (strong) NSURL *url;

@end
