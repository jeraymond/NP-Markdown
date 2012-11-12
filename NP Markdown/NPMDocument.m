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

#import "NPMDocument.h"
#import "NPMWindowController.h"
#import "NPMData.h"
#import "NPMRenderer.h"
#import "NPMLog.h"

@implementation NPMDocument {}

#pragma mark Document

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NPMData alloc] init];
        self.renderer = [[NPMRenderer alloc] initWithData:self.data];
    }
    return self;
}

- (void)makeWindowControllers
{
    NPMWindowController *windowController = [[NPMWindowController alloc] init];
    windowController.data = self.data;
    windowController.renderer = self.renderer;
    [self addWindowController:windowController];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSString *text = self.data.text;
    if (text && text.length > 0) {
        BOOL success = [text writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:outError];
        if (!success) {
            DDLogError(@"Error saving to %@: %@", [url absoluteString], [*outError localizedDescription]);
        }
        return success;
    }
    // TODO: localized error message
    NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
    NSString *errorDescription = @"The document is empty.";
    [errorUserInfo setObject:errorDescription forKey:NSLocalizedDescriptionKey];
    [errorUserInfo setObject:errorDescription forKey:NSLocalizedFailureReasonErrorKey];
    *outError = [NSError errorWithDomain:@"NPMErrorDomain" code:0 userInfo:errorUserInfo];
    return NO;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSStringEncoding encoding;
    NSString *text = [[NSString alloc] initWithContentsOfURL:url usedEncoding:&encoding error:outError];
    if (text) {
        self.data.text = text;
        return YES;
    }
    DDLogError(@"Error reading from %@: %@", [url absoluteString], [*outError localizedDescription]);
    return NO;
}

@end
