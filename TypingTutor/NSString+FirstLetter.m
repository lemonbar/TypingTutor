//
//  NSString+FirstLetter.m
//  TypingTutor
//
//  Created by Meng Li on 14-7-16.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import "NSString+FirstLetter.h"

@implementation NSString (FirstLetter)

- (NSString *)bnr_firstLetter
{
    if ([self length] < 2) {
        return self;
    }
    NSRange r;
    r.location = 0;
    r.length = 1;
    return [self substringWithRange:r];
}

@end
