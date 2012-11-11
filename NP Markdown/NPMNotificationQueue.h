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
  The notification that indicates the model data has changed.
 */
static NSString * const NPMNotificationDataChanged = @"NPMNotificationDataChanged";

/**
  The notification that indicates the model data has been rendered.
 */
static NSString * const NPMNotificationRenderComplete = @"NPMNotificationRenderComplete";

/**
  FIFO ordered notification queue.
 */
@interface NPMNotificationQueue : NSObject

/**
  Enqueues a notification with the given name on the main thread.
  @param name the notification name
  @param object the object for the notification
 */
+ (void)enqueueNotificationWithName:(NSString *)name object:(NSObject *)object;

/**
  Adds an observer to the notification center.
  @param observer the observer
  @param selector the selector to invoke on notification
  @param name the notification name
  @object object the sender
 */
+ (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(NSObject *)object;

/**
  Removes an observer from the notification center.
  @param observer the observer to remove
  @param name the name of the notification from which to be removed
  @param object the sender
 */
+ (void)removeObserver:(id)observer name:(NSString *)name object:(NSObject *)object;

@end
