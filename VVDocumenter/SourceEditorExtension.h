//
//  SourceEditorExtension.h
//  VVDocumenter
//
//  Created by Serhii Londar on 11/15/17.
//  Copyright © 2017 slon. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>
#import "VVDocumenterManager.h"

@interface SourceEditorExtension : NSObject <XCSourceEditorExtension>

@property(nonatomic, strong) VVDocumenterManager *documenterManager;

@end
