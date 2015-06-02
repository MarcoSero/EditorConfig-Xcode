//
//  ECEditorConfigWrapper.h
//  EditorConfig
//
//  Created by Marco Sero on 02/06/2015.
//  Copyright (c) 2015 Marco Sero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECEditorConfigPlugin.h"

FOUNDATION_EXPORT NSString *const ECIndentStyleKey;
FOUNDATION_EXPORT NSString *const ECIndentSizeKey;
FOUNDATION_EXPORT NSString *const ECTabWidthKey;

@interface ECEditorConfigWrapper : NSObject

+ (NSDictionary *)editorConfigurationForFileURL:(NSURL *)fileURL;

@end
