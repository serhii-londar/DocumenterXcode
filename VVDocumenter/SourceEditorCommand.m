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
    NSInteger currentLine = textRange.start.line;
    if(invocation.buffer.lines.count - 1 == currentLine) {
        completionHandler([[NSError alloc] initWithDomain:@"Error Inserting documentation in last line." code:500 userInfo:@{}]);
    }
    
    NSInteger methodLine = currentLine + 1;
    
    
    NSMutableString *methodString = [self detectMethodStringFromLine:methodLine inBuffer:invocation.buffer];
    if(methodString == nil) {
        completionHandler(nil);
        return;
    }
    VVDocumenter* doc = [[VVDocumenter alloc] initWithCode:methodString];
    NSString *documentation = [doc document];
    if(documentation == nil){
        completionHandler(nil);
        return;
    }
    
    [self insertDocumentation:documentation buffer:invocation.buffer line:currentLine];
    
    completionHandler(nil);
}

- (void)insertDocumentation:(NSString *)documentation buffer:(XCSourceTextBuffer *)buffer line: (NSInteger)line {
    NSArray<NSString *> *documentationArray = [documentation componentsSeparatedByString:@"\n"];
    for (NSInteger i = 0; i < documentationArray.count; i++) {
        NSString *lineToInsert = documentationArray[documentationArray.count - i - 1];
        [buffer.lines insertObject:lineToInsert atIndex:line];
    }
}

- (NSMutableString *)detectMethodStringFromLine:(NSInteger)line inBuffer:(XCSourceTextBuffer *)buffer {
    NSMutableString *methodString = [buffer.lines[line] mutableCopy];
    NSInteger currentLine = line;
    if([methodString containsString:@"func"] == YES) {
        while ([methodString containsString: @"{"] == NO) {
            if(buffer.lines.count - 1 == currentLine) {
                return nil;
            }
            currentLine += 1;
            [methodString appendString:buffer.lines[currentLine]];
        }
        return methodString;
    } else if([methodString containsString:@"-"]) {
        while ([methodString containsString: @";"] == NO) {
            if(buffer.lines.count - 1 == currentLine) {
                return nil;
            }
            currentLine += 1;
            [methodString appendString:buffer.lines[currentLine]];
        }
        return methodString;
    } else {
        return nil;
    }
}

@end
