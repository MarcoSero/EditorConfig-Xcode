//
//  ECEditorConfigWrapper.m
//  EditorConfig
//
//  Created by Marco Sero on 02/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import "ECEditorConfigWrapper.h"
#import <editorconfig/editorconfig.h>

NSString *const ECIndentStyleKey = @"indent_style";
NSString *const ECIndentSizeKey = @"indent_size";
NSString *const ECTabWidthKey = @"tab_width";

@implementation ECEditorConfigWrapper

+ (NSDictionary *)editorConfigurationForFileURL:(NSURL *)fileURL
{
  if (!fileURL) {
    ECLog(@"No file URL");
    return nil;
  }
  
  editorconfig_handle eh = editorconfig_handle_init();
  
  const char *filepath = fileURL.fileSystemRepresentation;
  int err_num = editorconfig_parse(filepath, eh);
  
  if (err_num != 0) {
    ECLog(@"%s", editorconfig_get_error_msg(err_num));
    if (err_num > 0) {
      ECLog(@"%s", editorconfig_handle_get_err_file(eh));
    }
    return nil;
  }
  
  NSMutableDictionary *config = [NSMutableDictionary dictionary];
  int name_value_count = editorconfig_handle_get_name_value_count(eh);
  for (int j = 0; j < name_value_count; ++j) {
    const char *name;
    const char *value;
    editorconfig_handle_get_name_value(eh, j, &name, &value);
    config[[NSString stringWithUTF8String:name]] = [NSString stringWithUTF8String:value];
  }
  
  if (editorconfig_handle_destroy(eh) != 0) {
    ECLog(@"Failed to destroy editorconfig_handle.");
  }
  
  return config;
}

@end
