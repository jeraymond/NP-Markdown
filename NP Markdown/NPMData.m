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

#import "NPMData.h"
#import "NPMNotificationQueue.h"

@implementation NPMData {
    NSString *_text;
}

#pragma mark NSObject

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark Model

- (void)setText:(NSString *)text
{
    @synchronized(self) {
        _text = text;
    }
    [NPMNotificationQueue enqueueNotificationWithName:NPMNotificationDataChanged object:self];
}

- (NSString *)text
{
    @synchronized(self) {
        return _text;
    }
}

@end
