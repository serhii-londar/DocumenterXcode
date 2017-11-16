//
//  SourceEditorExtension.m
//  VVDocumenter
//
//  Created by Serhii Londar on 11/15/17.
//  Copyright © 2017 slon. All rights reserved.
//

#import "SourceEditorExtension.h"

@implementation SourceEditorExtension

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)extensionDidFinishLaunching {
    self.documenterManager = [VVDocumenterManager shared];
    [self.documenterManager addSettingMenu];
    [self.documenterManager subscribeToEvents];
}


//- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions {
//    return @[];
//}

- (void)dealloc {
    
}

@end
