//
//  VVDocumenterSetting.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-8-3.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "VVDocumenterSetting.h"
#import <Carbon/Carbon.h>

NSString *const VVDDefaultTriggerString = @"///";
NSString *const VVDDefaultAuthorString = @"";
NSString *const VVDDefaultDateInfomationFormat = @"YY-MM-dd HH:MM:ss";

NSString *const kVVDUseSpaces = @"com.onevcat.VVDocumenter.useSpaces";
NSString *const kVVDSpaceCount = @"com.onevcat.VVDocumenter.spaceCount";
NSString *const kVVDTriggerString = @"com.onevcat.VVDocumenter.triggerString";
NSString *const kVVDPrefixWithStar = @"com.onevcat.VVDocumenter.prefixWithStar";
NSString *const kVVDPrefixWithSlashes = @"com.onevcat.VVDocumenter.prefixWithSlashes";
NSString *const kVVDAddSinceToComments = @"com.onevcat.VVDocumenter.addSinceToComments";
NSString *const kVVDSinceVersion = @"com.onevcat.VVDocumenter.sinceVersion";
NSString *const kVVDSinceOption = @"com.onevcat.VVDocumenter.sinceOption";
NSString *const kVVDBriefDescription = @"com.onevcat.VVDocumenter.briefDescription";
NSString *const kVVDUserHeaderDoc = @"com.onevcat.VVDocumenter.useHeaderDoc";
NSString *const kVVDNoBlankLinesBetweenFields = @"com.onevcat.VVDocumenter.noBlankLinesBetweenFields";
NSString *const kVVDNoArgumentPadding = @"com.onevcat.VVDocumenter.noArgumentPadding";
NSString *const kVVDUseAuthorInformation = @"com.onevcat.VVDocumenter.useAuthorInformation";
NSString *const kVVDAuthorInfomation = @"com.onevcat.VVDocumenter.authorInfomation";
NSString *const kVVDUseDateInformation = @"com.onevcat.VVDocumenter.useDateInformation";
NSString *const kVVDDateInformationFormat = @"com.onevcat.VVDocumenter.dateInformationFomat";


@implementation VVDocumenterSetting {
    NSUserDefaults *myDefaults;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"22AFPHX3AU.com.slon.Documenter"];
        
        NSDictionary *defaults = @{kVVDPrefixWithStar: @YES,
                                   kVVDUseSpaces: @YES,
                                   kVVDAuthorInfomation: @""
                                   };
        [myDefaults registerDefaults:defaults];
        [myDefaults synchronize];
    }
    return self;
}

+ (VVDocumenterSetting *)defaultSetting
{
    static dispatch_once_t once;
    static VVDocumenterSetting *defaultSetting;
    dispatch_once(&once, ^ {
        defaultSetting = [[VVDocumenterSetting alloc] init];
    });
    return defaultSetting;
}

-(BOOL) useSpaces
{
    return [myDefaults boolForKey:kVVDUseSpaces];
}

-(void) setUseSpaces:(BOOL)useSpace
{
    [myDefaults setBool:useSpace forKey:kVVDUseSpaces];
    [myDefaults synchronize];
}

-(NSInteger) keyVCode
{
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
    NSString *layoutID = (__bridge NSString *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    CFRelease(inputSource);

    // Possible dvorak layout SourceIDs:
    //    com.apple.keylayout.Dvorak (System Qwerty)
    // But exclude:
    //    com.apple.keylayout.DVORAK-QWERTYCMD (System Qwerty ⌘)
    //    org.unknown.keylayout.DvorakImproved-Qwerty⌘ (http://www.macupdate.com/app/mac/24137/dvorak-improved-keyboard-layout)
    if ([layoutID localizedCaseInsensitiveContainsString:@"dvorak"] && ![layoutID localizedCaseInsensitiveContainsString: @"qwerty"]) {
        return kVK_ANSI_Period;
    }

    // Possible workman layout SourceIDs (https://github.com/ojbucao/Workman):
    //    org.sil.ukelele.keyboardlayout.workman.workman
    //    org.sil.ukelele.keyboardlayout.workman.workmanextended
    //    org.sil.ukelele.keyboardlayout.workman.workman-io
    //    org.sil.ukelele.keyboardlayout.workman.workman-p
    //    org.sil.ukelele.keyboardlayout.workman.workman-pextended
    //    org.sil.ukelele.keyboardlayout.workman.workman-dead
    if ([layoutID localizedCaseInsensitiveContainsString:@"workman"]) {
        return kVK_ANSI_B;
    }

    return kVK_ANSI_V;
}


-(NSInteger) spaceCount
{
    NSInteger count = [myDefaults integerForKey:kVVDSpaceCount];
    return (count <= 0) ? 2 : count;
}

-(void) setSpaceCount:(NSInteger)spaceCount
{
    if (spaceCount < 1) {
        spaceCount = 1;
    } else if (spaceCount > 10) {
        spaceCount = 10;
    }
    
    [myDefaults setInteger:spaceCount forKey:kVVDSpaceCount];
    [myDefaults synchronize];
}

-(NSString *) triggerString
{
    NSString *s = [myDefaults stringForKey:kVVDTriggerString];
    if (s.length == 0) {
        s = VVDDefaultTriggerString;
    }
    return s;
}

-(void) setTriggerString:(NSString *)triggerString
{
    if (triggerString.length == 0) {
        [myDefaults setObject:VVDDefaultTriggerString forKey:kVVDTriggerString];
    } else {
        [myDefaults setObject:triggerString forKey:kVVDTriggerString];
    }

    [myDefaults synchronize];
}

-(VVDSinceOption) sinceOption
{
    return (VVDSinceOption)[myDefaults integerForKey:kVVDSinceOption];
}

- (void)setSinceOption:(VVDSinceOption)sinceOption
{
    [myDefaults setInteger:sinceOption forKey:kVVDSinceOption];
    [myDefaults synchronize];
}

-(BOOL) prefixWithStar
{
    return [myDefaults boolForKey:kVVDPrefixWithStar];
}

-(void) setPrefixWithStar:(BOOL)prefix
{
    [myDefaults setBool:prefix forKey:kVVDPrefixWithStar];
    [myDefaults synchronize];
}

-(BOOL) prefixWithSlashes
{
    return [myDefaults boolForKey:kVVDPrefixWithSlashes];
}

-(void) setPrefixWithSlashes:(BOOL)prefix
{
    [myDefaults setBool:prefix forKey:kVVDPrefixWithSlashes];
    [myDefaults synchronize];
}

-(BOOL) addSinceToComments
{
    return [myDefaults boolForKey:kVVDAddSinceToComments];
}

-(void) setAddSinceToComments:(BOOL)add
{
    [myDefaults setBool:add forKey:kVVDAddSinceToComments];
    [myDefaults synchronize];
}

- (NSString *)sinceVersion
{
    NSString *sinceVersion = [myDefaults objectForKey:kVVDSinceVersion];

    if ( ! sinceVersion ) {
        sinceVersion = @"";
    }

    return sinceVersion;
}

- (void)setSinceVersion:(NSString *)sinceVersion
{
    [myDefaults setObject:sinceVersion forKey:kVVDSinceVersion];
    [myDefaults synchronize];
}

-(BOOL) briefDescription
{
    return [myDefaults boolForKey:kVVDBriefDescription];
}

-(void) setBriefDescription:(BOOL)brief
{
    [myDefaults setBool:brief forKey:kVVDBriefDescription];
    [myDefaults synchronize];
}

-(BOOL) useHeaderDoc
{
    return [myDefaults boolForKey:kVVDUserHeaderDoc];
}
-(void) setUseHeaderDoc:(BOOL)use
{
    [myDefaults setBool:use forKey:kVVDUserHeaderDoc];
    [myDefaults synchronize];
}

-(BOOL) blankLinesBetweenSections
{
    return ![myDefaults boolForKey:kVVDNoBlankLinesBetweenFields];
}
-(void) setBlankLinesBetweenSections:(BOOL)blankLinesBetweenFields
{
    [myDefaults setBool:!blankLinesBetweenFields forKey:kVVDNoBlankLinesBetweenFields];
    [myDefaults synchronize];
}

-(BOOL) alignArgumentComments
{
    return ![myDefaults boolForKey:kVVDNoArgumentPadding];
}
-(void) setAlignArgumentComments:(BOOL)alignArgumentComments
{
    [myDefaults setBool:!alignArgumentComments forKey:kVVDNoArgumentPadding];
    [myDefaults synchronize];
}

-(BOOL)useAuthorInformation
{
    return [myDefaults boolForKey:kVVDUseAuthorInformation];
}
-(void) setUseAuthorInformation:(BOOL)useAuthorInformation
{
    [myDefaults setBool:useAuthorInformation forKey:kVVDUseAuthorInformation];
    [myDefaults synchronize];
}

-(NSString *)authorInformation {
    return [myDefaults objectForKey:kVVDAuthorInfomation];
}

-(void)setAuthorInformation:(NSString *)authorInformation {
    [myDefaults setObject:authorInformation forKey:kVVDAuthorInfomation];
    [myDefaults synchronize];
}

-(BOOL)useDateInformation
{
    return [myDefaults boolForKey:kVVDUseDateInformation];
}
-(void) setUseDateInformation:(BOOL)useDateInformation
{
    [myDefaults setBool:useDateInformation forKey:kVVDUseDateInformation];
    [myDefaults synchronize];
}

-(NSString *)dateInformationFormat {
    NSString *formatString = [myDefaults objectForKey:kVVDDateInformationFormat];
    if (formatString == nil || formatString.length <= 0) {
        formatString = VVDDefaultDateInfomationFormat;
    }
    return formatString;
}
-(void)setDateInformationFormat:(NSString *)dateInformationFormat {
    [myDefaults setObject:dateInformationFormat forKey:kVVDDateInformationFormat];
    [myDefaults synchronize];
}

-(NSString *) spacesString
{
    if ([self useSpaces]) {
        return [@"" stringByPaddingToLength:[self spaceCount] withString:@" " startingAtIndex:0];
    } else {
        return @"\t";
    }
}

@end
