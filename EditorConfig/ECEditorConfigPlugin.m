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
@property (nonatomic, strong) dispatch_queue_t updateSettingsQueue;

@property (nonatomic, assign) BOOL indentUsingTabs;
@property (nonatomic, strong) NSString *tabWidth;
@property (nonatomic, strong) NSString *indentWidth;

@property (nonatomic, strong) NSMenuItem *editorConfigMenuItem;
@property (nonatomic, strong) NSMenuItem *fileNotFoundItem;
@property (nonatomic, strong) NSMenuItem *indentStyleItem;
@property (nonatomic, strong) NSMenuItem *tabWidthItem;
@property (nonatomic, strong) NSMenuItem *indentWidthItem;

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
  
  NSLog(@"EditorConfig Plugin Loaded.");
  
  _bundle = plugin;
  _updateSettingsQueue = dispatch_queue_create("com.marcosero.EditorConfig.queue", DISPATCH_QUEUE_SERIAL);
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onFileChangeNotification:)
                                               name:IDEEditorDocumentDidChangeNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(menuDidChange:)
                                               name:NSMenuDidChangeItemNotification
                                             object:nil];
  return self;
}

- (void)menuDidChange:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSMenuDidChangeItemNotification
                                                object:nil];
  
  [self createMenuItem];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(menuDidChange:)
                                               name:NSMenuDidChangeItemNotification
                                             object:nil];
}

- (void)createMenuItem
{
  NSMenuItem * editorMenuItem = [[NSApp mainMenu] itemWithTitle:@"Editor"];
  NSString *editorConfigMenuTitle = @"Editor Config";
  if (editorMenuItem && ![editorMenuItem.submenu itemWithTitle:editorConfigMenuTitle]) {
    
    self.editorConfigMenuItem = [[NSMenuItem alloc] initWithTitle:editorConfigMenuTitle
                                                                  action:NULL
                                                           keyEquivalent:@""];
    [self.editorConfigMenuItem setTarget:self];
    
    self.indentStyleItem = [[NSMenuItem alloc] initWithTitle:[self indentStyleString]
                                                      action:NULL
                                               keyEquivalent:@""];
    
    self.tabWidthItem = [[NSMenuItem alloc] initWithTitle:[self tabWidthString]
                                                   action:NULL
                                            keyEquivalent:@""];
    
    self.indentWidthItem = [[NSMenuItem alloc] initWithTitle:[self indentWidthString]
                                                      action:NULL
                                               keyEquivalent:@""];
    
    self.editorConfigMenuItem.submenu = [[NSMenu alloc] initWithTitle:@""];
    [self.editorConfigMenuItem.submenu addItem:self.indentStyleItem];
    [self.editorConfigMenuItem.submenu addItem:self.tabWidthItem];
    [self.editorConfigMenuItem.submenu addItem:self.indentWidthItem];
    
    [editorMenuItem.submenu addItem:[NSMenuItem separatorItem]];
    [editorMenuItem.submenu addItem:self.editorConfigMenuItem];
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onFileChangeNotification:(NSNotification *)notification
{
  NSDocument *currentDocument = notification.object;
  if (![currentDocument respondsToSelector:@selector(fileURL)]) {
    return;
  }
  dispatch_async(self.updateSettingsQueue, ^{
    [self updateSettingsForFileURL:currentDocument.fileURL];
  });
}

- (void)updateSettingsForFileURL:(NSURL *)fileURL
{
  NSDictionary *editorConfig = [ECEditorConfigWrapper editorConfigurationForFileURL:fileURL];
  
  NSString *indentStyleFromConfigFile = editorConfig[ECIndentStyleKey];
  NSString *indentWidthFromConfigFile = editorConfig[ECIndentSizeKey];
  NSString *tabWidthFromConfigFile = editorConfig[ECTabWidthKey];
  
  self.configFileFound = (indentStyleFromConfigFile != nil) | (indentWidthFromConfigFile != nil) | (tabWidthFromConfigFile != nil);
  
  if (indentStyleFromConfigFile) {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.indentUsingTabs) forKey:@"DVTTextIndentUsingTabs"];
    self.indentUsingTabs = [indentStyleFromConfigFile isEqualToString:@"tab"];
    NSLog(@"EditorConfig: Updated %@ to %@", ECIndentStyleKey, self.indentUsingTabs ? @"tab" : @"space");
  }
  
  if (indentWidthFromConfigFile) {
    [[NSUserDefaults standardUserDefaults] setObject:indentWidthFromConfigFile forKey:@"DVTTextIndentWidth"];
    self.indentWidth = indentWidthFromConfigFile;
    NSLog(@"EditorConfig: Updated %@ to %@", ECIndentSizeKey, self.indentWidth);
  }
  
  if (tabWidthFromConfigFile) {
    [[NSUserDefaults standardUserDefaults] setObject:tabWidthFromConfigFile forKey:@"DVTTextIndentTabWidth"];
    self.tabWidth = tabWidthFromConfigFile;
    NSLog(@"EditorConfig: Updated %@ to %@", ECTabWidthKey, self.tabWidth);
  }
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Setters
- (void)setIndentUsingTabs:(BOOL)indentUsingTabs
{
  _indentUsingTabs = indentUsingTabs;
  self.indentStyleItem.title = [self indentStyleString];
}

- (void)setTabWidth:(NSString *)tabWidth
{
  _tabWidth = tabWidth;
  self.tabWidthItem.title = [self tabWidthString];
}

- (void)setIndentWidth:(NSString *)indentWidth
{
  _indentWidth = indentWidth;
  self.indentWidthItem.title = [self indentWidthString];
}

#pragma mark - Helpers
- (void)setConfigFileFound:(BOOL)configFileFound
{
  _configFileFound = configFileFound;
  
  if (configFileFound)
  {
    if ([self.editorConfigMenuItem.submenu indexOfItem:self.fileNotFoundItem] >= 0)
    {
      [self.editorConfigMenuItem.submenu removeItem:self.fileNotFoundItem];
    }
  }
  else
  {
    if ([self.editorConfigMenuItem.submenu indexOfItem:self.fileNotFoundItem] == -1)
    {
      self.fileNotFoundItem = [[NSMenuItem alloc] initWithTitle:@".editorconfig Not Loaded, Using Default Settings"
                                                         action:NULL
                                                  keyEquivalent:@""];
      [self.editorConfigMenuItem.submenu insertItem:self.fileNotFoundItem atIndex:0];
    }
  }
}

- (NSString *)indentStyleString
{
  BOOL indentUsingTabs = [[NSUserDefaults standardUserDefaults] boolForKey:@"DVTTextIndentUsingTabs"];
  return [NSString stringWithFormat:@"Indent Style: %@", indentUsingTabs ? @"Tabs" : @"Spaces"];
}

- (NSString *)tabWidthString
{
  NSString *tabWidth = [[NSUserDefaults standardUserDefaults] stringForKey:@"DVTTextIndentTabWidth"];
  return [NSString stringWithFormat:@"Tab Width: %@", tabWidth];
}

- (NSString *)indentWidthString
{
  NSString *indentWidth = [[NSUserDefaults standardUserDefaults] stringForKey:@"DVTTextIndentWidth"];
  return [NSString stringWithFormat:@"Indent Width: %@", indentWidth];
}

@end
