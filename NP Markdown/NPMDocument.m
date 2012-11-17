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
#import "NPMNotificationQueue.h"
#import "VDKQueue.h"

@implementation NPMDocument {
    NPMWindowController *_windowController;
    VDKQueue *_vdkQueue;
}

#pragma mark Document

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NPMData alloc] init];
        self.renderer = [[NPMRenderer alloc] initWithData:self.data];
        _vdkQueue = [[VDKQueue alloc] init];
        _vdkQueue.delegate = self;
    }
    return self;
}

- (void)makeWindowControllers
{
    _windowController = [[NPMWindowController alloc] initWithData:self.data andRenderer:self.renderer];
    [self addWindowController:_windowController];
    [NPMNotificationQueue addObserver:self selector:@selector(changeFileModeToWatch:) name:NPMNotificationChangeFileModeToWatch object:_windowController];
    [NPMNotificationQueue addObserver:self selector:@selector(changeFileModeToEdit:) name:NPMNotificationChangeFileModeToEdit object:_windowController];
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
        if (success) {
            if (self.fileURL){
                self.data.url = self.fileURL;
            } else {
                self.data.url = url;
            }
            [NPMNotificationQueue enqueueNotificationWithName:NPMNotificationDataSaved object:self.data];
        } else {
            DDLogError(@"Error saving to %@: %@", [url absoluteString], [*outError localizedDescription]);
        }
        return success;
    }

    NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
    NSString *errorDescription = @"The document is empty.";
    [errorUserInfo setObject:errorDescription forKey:NSLocalizedDescriptionKey];
    [errorUserInfo setObject:errorDescription forKey:NSLocalizedFailureReasonErrorKey];
    *outError = [NSError errorWithDomain:@"NPMErrorDomain" code:0 userInfo:errorUserInfo];
    return NO;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    self.data.url = self.fileURL;
    NSStringEncoding encoding;
    NSString *text = [[NSString alloc] initWithContentsOfURL:url usedEncoding:&encoding error:outError];
    if (text) {
        self.data.text = text;
        return YES;
    }
    DDLogError(@"Error reading from %@: %@", [url absoluteString], [*outError localizedDescription]);
    return NO;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    SEL theAction = [anItem action];
    if (_windowController.currentFileMode == WATCH && (theAction == @selector(saveDocument:) || theAction == @selector(revertDocumentToSaved:))) {
        return NO;
    }
    return [super validateUserInterfaceItem:anItem];

}

#pragma mark File Mode

- (void)changeFileModeToWatch:(NSNotification *)notification
{
    [_windowController enableWatchMode];
    [self watchForChanges];
}

- (void)changeFileModeToEdit:(NSNotification *)notification
{
    [self doNotWatchForChanges];
}

#pragma mark File Watching

/**
 * Delegate protocol method for VDKQueue file change notifications.
 */
-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath
{
    DDLogInfo(@"Contents changed for watched file %@", fpath);
    NSError *error;
    if ([self readFromURL:self.fileURL ofType:nil error:&error]) {
        DDLogInfo(@"Successfully read data from %@", self.fileURL.path);
    } else {
        DDLogError(@"Error reading data from %@", self.fileURL.path);
    }
}

- (void)watchForChanges
{
    [_vdkQueue addPath:[self.fileURL path] notifyingAbout:VDKQueueNotifyAboutWrite];
    DDLogInfo(@"Watching file %@ for changes on save", [self.fileURL path]);
}

- (void)doNotWatchForChanges
{
    [_vdkQueue removePath:[self.fileURL path]];
    DDLogInfo(@"Stopped watching file %@ for changes on save", [self.fileURL path]);
}

@end
