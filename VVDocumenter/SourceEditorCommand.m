//
//  SourceEditorCommand.m
//  VVDocumenter
//
//  Created by Serhii Londar on 11/15/17.
//  Copyright © 2017 slon. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "VVDocumenter.h"

@implementation SourceEditorCommand
    
- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    XCSourceTextRange *textRange = invocation.buffer.selections.firstObject;
    NSInteger indexToInsert = textRange.start.line + 1;
    
    
    NSInteger currentLine = textRange.start.line;
    NSInteger methodLine = currentLine + 1;
    NSMutableString *methodString = [invocation.buffer.lines[methodLine] mutableCopy];
    BOOL isSwift;
    if([methodString containsString:@"-"]) {
        isSwift = NO;
    } else if([methodString containsString:@"func"]) {
        isSwift = YES;
    } else {
        completionHandler(nil);
        return;
    }
    while ([methodString containsString: isSwift ? @"{" : @";"] == false) {
        if(invocation.buffer.lines.count == currentLine) {
            completionHandler(nil);
            return;
        }
        methodLine += 1;
        [methodString appendString:invocation.buffer.lines[methodLine]];
    }
    
    
    
    
    VVDocumenter* doc = [[VVDocumenter alloc] initWithCode:methodString];
    NSString *documentation = [doc document];
    
    NSArray<NSString *> *documentationArray = [documentation componentsSeparatedByString:@"\n"];
    
    for (NSInteger i = 0; i < documentationArray.count; i++) {
        NSString *lineToInsert = documentationArray[documentationArray.count - i - 1];
        [invocation.buffer.lines insertObject:lineToInsert atIndex:indexToInsert];
    }
    
    completionHandler(nil);
}

@end
