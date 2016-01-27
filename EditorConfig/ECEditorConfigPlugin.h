//
//  EditorConfig.h
//  EditorConfig
//
//  Created by Marco Sero on 01/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <AppKit/AppKit.h>

#define ECLog(fmt, ...) NSLog((@"EditorConfigPlugin | %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@class ECEditorConfigPlugin;

static ECEditorConfigPlugin *sharedPlugin;

@interface ECEditorConfigPlugin : NSObject

@property (nonatomic, strong, readonly) NSBundle* bundle;
@property (nonatomic, assign) BOOL configFileFound;

+ (instancetype)sharedPlugin;

- (id)initWithBundle:(NSBundle *)plugin;

@end