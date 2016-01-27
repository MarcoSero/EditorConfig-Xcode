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
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(menuDidChange:)
                                               name: NSMenuDidChangeItemNotification
                                             object: nil];
  return self;
}

- (void) menuDidChange: (NSNotification *) notification {
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: NSMenuDidChangeItemNotification
                                                object: nil];
  
  [self createMenuItem];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(menuDidChange:)
                                               name: NSMenuDidChangeItemNotification
                                             object: nil];
}

- (void)createMenuItem
{
  NSMenuItem * editorMenuItem = [[NSApp mainMenu] itemWithTitle: @"Editor"];
  if (editorMenuItem && ![editorMenuItem.submenu itemWithTitle:@"Editor Config"]) {
    
    
    NSMenuItem *editorConfigMenuItem = [[NSMenuItem alloc] initWithTitle:@"Editor Config"
                                                                  action:NULL
                                                           keyEquivalent:@""];
    [editorConfigMenuItem setTarget:self];
    
    self.indentStyleItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Indent Style: %@", _indentUsingTabs ? @"Tabs" : @"Spaces"]
                                                      action:NULL
                                               keyEquivalent:@""];
    
    self.tabWidthItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Tab Width: %@", _tabWidth]
                                                   action:NULL
                                            keyEquivalent:@""];
    
    self.indentWidthItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Indent Width: %@", _indentWidth]
                                                      action:NULL
                                               keyEquivalent:@""];
    
    editorConfigMenuItem.submenu = [[NSMenu alloc] initWithTitle:@""];
    [editorConfigMenuItem.submenu addItem:self.indentStyleItem];
    [editorConfigMenuItem.submenu addItem:self.tabWidthItem];
    [editorConfigMenuItem.submenu addItem:self.indentWidthItem];
    
    [editorMenuItem.submenu addItem:[NSMenuItem separatorItem]];
    [editorMenuItem.submenu addItem:editorConfigMenuItem];
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
  
  if (editorConfig[ECIndentStyleKey]) {
    self.indentUsingTabs = [editorConfig[ECIndentStyleKey] isEqualToString:@"tab"];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.indentUsingTabs) forKey:@"DVTTextIndentUsingTabs"];
    NSLog(@"EditorConfig: Updated %@ to %@", ECIndentStyleKey, self.indentUsingTabs ? @"tab" : @"space");
  }
  
  if (editorConfig[ECIndentSizeKey]) {
    [[NSUserDefaults standardUserDefaults] setObject:editorConfig[ECIndentSizeKey] forKey:@"DVTTextIndentWidth"];
    self.indentWidth = editorConfig[ECIndentSizeKey];
    NSLog(@"EditorConfig: Updated %@ to %@", ECIndentSizeKey, self.indentWidth);
  }
  
  if (editorConfig[ECTabWidthKey]) {
    [[NSUserDefaults standardUserDefaults] setObject:editorConfig[ECTabWidthKey] forKey:@"DVTTextIndentTabWidth"];
    self.tabWidth = editorConfig[ECTabWidthKey];
    NSLog(@"EditorConfig: Updated %@ to %@", ECTabWidthKey, self.tabWidth);
  }
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Setters
- (void)setIndentUsingTabs:(BOOL)indentUsingTabs
{
  _indentUsingTabs = indentUsingTabs;
  self.indentStyleItem.title = [NSString stringWithFormat:@"Indent Style: %@", _indentUsingTabs ? @"Tabs" : @"Spaces"];
}

- (void)setTabWidth:(NSString *)tabWidth
{
  _tabWidth = tabWidth;
  self.tabWidthItem.title = [NSString stringWithFormat:@"Tab Width: %@", _tabWidth];
}

- (void)setIndentWidth:(NSString *)indentWidth
{
  _indentWidth = indentWidth;
  self.indentWidthItem.title = [NSString stringWithFormat:@"Indent Width: %@", _indentWidth];
}

@end
