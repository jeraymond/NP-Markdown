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

#import "NPMLog.h"
#import "NPMStyle.h"
#import "NPMNotificationQueue.h"

static NSString * const NPMStyleUserDefaultsDefaultStyleKey = @"NPMStyleUserDefaultsDefaultStyleKey";

@implementation NPMStyle {
    NSString *_selectedStyle;
}

#pragma mark Init

- (id)init
{
    self = [super init];
    if (self) {
        [self initTemplateNames];
    }
    return self;
}

- (void)initTemplateNames
{
    NSMutableArray *names = [[NSMutableArray alloc] init];

    for (NSDictionary *dict in [self templatePaths]) {
        [names addObject:[dict objectForKey:@"name"]];
    }
    self.styleNames = names;
}

#pragma mark Properties

- (void)setSelectedStyle:(NSString *)currentStyle
{
    _selectedStyle = currentStyle;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:currentStyle forKey:NPMStyleUserDefaultsDefaultStyleKey];
    [prefs synchronize];
    [NPMNotificationQueue enqueueNotificationWithName:NPMNotificationStyleChanged object:self];
}

- (NSString *)selectedStyle
{
    return _selectedStyle;
}

- (NSString *)defaultStyle
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *style = [prefs stringForKey:NPMStyleUserDefaultsDefaultStyleKey];
    if (style) {
        return style;
    }
    return [self.styleNames objectAtIndex:0];
}

- (NSURL *)selectedStyleTemplateRoot
{
    NSString *styleTemplatePath = [[NSBundle mainBundle] resourcePath];
    styleTemplatePath = [styleTemplatePath stringByAppendingFormat:@"/StyleTemplates/%@", self.selectedStyle];
    return [NSURL fileURLWithPath:styleTemplatePath];
}

#pragma mark Style

- (NSString *)applyStyle:(NSString *)style toHtml:(NSString *)html
{
    NSPredicate *styleFilter = [NSPredicate predicateWithFormat:@"name = %@", style];
    NSArray *templatePaths = [[self templatePaths] filteredArrayUsingPredicate:styleFilter];
    NSString *styledHtml = html;

    if (templatePaths.count == 1) {
        // Determine template path
        NSDictionary *templateInfo = [templatePaths objectAtIndex:0];
        NSString *styleTemplatePath = [[NSBundle mainBundle] resourcePath];
        styleTemplatePath = [styleTemplatePath stringByAppendingString:@"/StyleTemplates/"];
        styleTemplatePath = [styleTemplatePath stringByAppendingString:[templateInfo objectForKey:@"template"]];

        // Load template
        NSURL *styleTemplateUrl = [NSURL fileURLWithPath:styleTemplatePath];
        NSStringEncoding encoding;
        NSError *error;
        NSString *data = [[NSString alloc] initWithContentsOfURL:styleTemplateUrl usedEncoding:&encoding error:&error];

        // Apply the template
        if (data) {
            styledHtml = [data stringByReplacingOccurrencesOfString:@"{{markdown}}" withString:html];
            DDLogInfo(@"Applied style %@", style);
        } else {
            DDLogError(@"Error loading template %@ from %@ because of error %@", style, styleTemplatePath, [error localizedDescription]);
        }
    } else {
        DDLogError(@"Expected 1 template matching style %@ but found %ld", style, templatePaths.count);
    }

    return styledHtml;
}

#pragma mark Internal

- (NSArray *)templatePaths
{
    NSString *templatePlistPath = [[NSBundle mainBundle] pathForResource:@"/StyleTemplates/StyleInfo" ofType:@"plist"];
    NSArray *templatePaths = [NSArray arrayWithContentsOfFile:templatePlistPath];
    return templatePaths;
}

@end
