//
//  EditorConfig.m
//  EditorConfig
//
//  Created by Marco Sero on 01/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "ECEditorConfigPlugin.h"
#import "ECEditorConfigWrapper.h"

static NSString *IDEEditorDocumentDidChangeNotification = @"IDEEditorDocumentDidChangeNotification";

@interface ECEditorConfigPlugin ()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation ECEditorConfigPlugin

+ (instancetype)sharedPlugin
{
  return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
  self = [super init];
  if (!self) {
    return nil;
  }
  self.bundle = plugin;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onFileChangeNotification:)
                                               name:IDEEditorDocumentDidChangeNotification
                                             object:nil];
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onFileChangeNotification:(NSNotification *)notification
{
  NSDocument *currentDocument = notification.object;
  NSURL *fileURL = currentDocument.fileURL;
  NSDictionary *editorConfig = [ECEditorConfigWrapper editorConfigurationForFileURL:fileURL];
  
  if (editorConfig[ECIndentSizeKey]) {
    [[NSUserDefaults standardUserDefaults] setObject:editorConfig[ECIndentSizeKey] forKey:@"DVTTextIndentWidth"];
  }
  
  if (editorConfig[ECTabWidthKey]) {
    [[NSUserDefaults standardUserDefaults] setObject:editorConfig[ECTabWidthKey] forKey:@"DVTTextIndentTabWidth"];
  }
  
  if (editorConfig[ECIndentStyleKey]) {
    BOOL indentUsingTabs = [editorConfig[ECIndentStyleKey] isEqualToString:@"tab"];
    [[NSUserDefaults standardUserDefaults] setObject:@(indentUsingTabs) forKey:@"DVTTextIndentUsingTabs"];
  }
}

@end
