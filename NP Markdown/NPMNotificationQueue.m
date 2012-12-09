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

#import "NPMNotificationQueue.h"

@implementation NPMNotificationQueue {}

#pragma mark NPMNotificationQueue

+ (void)enqueueNotificationWithName:(NSString *)name object:(NSObject *)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotification *notification = [NSNotification notificationWithName:name object:object userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostNow
                                                   coalesceMask:NSNotificationCoalescingOnName forModes:nil];
    });
}

+ (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(NSObject *)object
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}

+ (void)removeObserver:(id)observer name:(NSString *)name object:(NSObject *)object
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
}


@end
