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

#import "NPMDataTests.h"
#import "NPMData.h"
#import "NPMNotificationQueue.h"

@implementation NPMDataTests {
    BOOL notificationReceived;
}

#pragma mark Test Get and Set

- (void)testSetAndGetText
{
    NPMData *data = [[NPMData alloc] init];
    data.text = @"The text";
    STAssertEqualObjects(data.text, @"The text", @"Data text was not set or retrieved correctly");
}

#pragma mark Test Data Change Notification

- (void)testNotificationNPMNotificationDataChanged
{
    notificationReceived = NO;
    [NPMNotificationQueue addObserver:self selector:@selector(gotNotification:) name:NPMNotificationDataChanged object:nil];

    NPMData *data = [[NPMData alloc] init];
    data.text = @"The text";
    [NSThread sleepForTimeInterval:1];

    STAssertTrue(notificationReceived, @"Did not receive %@ notification", NPMNotificationDataChanged);
}

- (void)gotNotification:(NSNotification *)notification
{
    notificationReceived = YES;
}

@end
