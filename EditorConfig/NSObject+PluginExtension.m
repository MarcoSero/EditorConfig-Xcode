//
//  NSObject_Extension.m
//  EditorConfig
//
//  Created by Marco Sero on 01/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//


#import "NSObject+PluginExtension.h"
#import "ECEditorConfigPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedPlugin = [[ECEditorConfigPlugin alloc] initWithBundle:plugin];
    });
  }
}

@end
