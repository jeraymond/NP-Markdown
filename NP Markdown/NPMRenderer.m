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

#import "NPMRenderer.h"
#import "NPMData.h"

@implementation NPMRenderer

#pragma mark NSObject

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class NPMRenderer"
                                 userInfo:nil];
    return nil;
}

#pragma mark Init

- (id)initWithData:(NPMData *)npmData
{
    self = [super init];
    if (self) {
        self.data = npmData;
        // TODO: actually render the model data
        self.html = [@"<h1>TODO: actually render the model data</h1>" stringByAppendingFormat:@"\n%@", self.data.text];
    }
    return self;
}

@end
