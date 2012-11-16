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

#import "NPMRendererTests.h"
#import "NPMRenderer.h"
#import "NPMNotificationQueue.h"
#import "NPMData.h"

@implementation NPMRendererTests {
    BOOL notificationReceived;
}

#pragma mark Test No Default Init

- (void)testNoDefaultInit
{
    STAssertThrows((void)[[NPMRenderer alloc] init], @"NPMRenderer init unexpectedly suceeded");
}

#pragma mark Test Render Complete Notification

- (void)testNotificationNPMNotificationDataChanged
{
    notificationReceived = NO;
    [NPMNotificationQueue addObserver:self selector:@selector(gotNotification:) name:NPMNotificationRenderComplete object:nil];

    NPMData *data = [[NPMData alloc] init];
    data.text = @"The text";
    [NSThread sleepForTimeInterval:1];
    STAssertFalse(notificationReceived, @"Unexpectedly received a notification");

    // Initial render on init.
    NPMRenderer *renderer __attribute__((unused)) = [[NPMRenderer alloc] initWithData:data];
    [NSThread sleepForTimeInterval:1];
    STAssertTrue(notificationReceived, @"Did not receive %@ notification", NPMNotificationDataChanged);

    // Render on data text updated
    notificationReceived = NO;
    data.text = @"Updated";
    [NSThread sleepForTimeInterval:1];
    STAssertTrue(notificationReceived, @"Did not receive %@ notification", NPMNotificationDataChanged);
}

- (void)gotNotification:(NSNotification *)notification
{
    notificationReceived = YES;
}

@end
