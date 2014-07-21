//
//  ColorFormatter.m
//  TypingTutor
//
//  Created by Meng Li on 14-7-18.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import "ColorFormatter.h"

    //private method.
@interface ColorFormatter ()
- (NSString *)firstColorKeyForPartialString:(NSString
                                             *)string;
@end

@implementation ColorFormatter
- (id)init
{
    self = [super init];
    if (self) {
        colorList = [NSColorList
                     colorListNamed:@"Apple"];
    }
    return self;
}

- (NSString *)firstColorKeyForPartialString:(NSString *)string
{
    //Is the key zero-length?
    if ([string length] == 0) {
        return nil;
    }
    //Loop through the color list
    for (NSString *key in [colorList allKeys]) {
        NSRange whereFound = [key rangeOfString:string
                                        options:NSCaseInsensitiveSearch];
        // Does the string match the beginning of the color name?
        if ((whereFound.location == 0) && (whereFound.length > 0)){
            return key;
        }
    }
    //If no match is found, return nil
    return nil;
}

//This message is sent by the control to the formatter when it has to
//convert anObject into a string. The control will display the string
//that is returned for the user
- (NSString *)stringForObjectValue:(id)obj
{
        // Not a color?
    if (![obj isKindOfClass:[NSColor class]]) {
        return nil;
    }
        // Convert to an RGB Color Space
    NSColor *color;
    color = [obj
             colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        // Get components as floats between 0 and 1
    CGFloat red, green, blue;
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:NULL];
        // Initialize the distance to something large
    float minDistance = 3.0;
    NSString *closestKey = nil;
        // Find the closest color
    for (NSString *key in [colorList allKeys]) {
        NSColor *c = [colorList colorWithKey:key];
        CGFloat r, g, b;
        [c getRed:&r
            green:&g
             blue:&b
            alpha:NULL];
            // How far apart are 'color' and 'c'?
        float dist;
        dist = pow(red - r, 2) + pow(green -g, 2) + pow
        (blue - b, 2);
            // Is this the closest yet?
        if (dist < minDistance) {
            minDistance = dist;
            closestKey = key;
        }
    }
        // Return the name of the closest color
    return closestKey;
}

//This message is sent by the control (such as a text field) to the
//formatter when it has to convert aString into an object; aString is
//the string that the user typed in. The formatter can return YES and set
//anObject to point to the new object. A return of NO indicates that the
//string could not be converted, and the errorPtr is set to indicate
//what went wrong. Note that errorPtr is a pointer to a pointer, as is
//anObject. That is, it is a location where you can put a pointer to the
//string.
- (BOOL)getObjectValue:(id *)obj
forString:(NSString *)string
errorDescription:(NSString **)errorString
{
    // Look up the color for 'string'
    NSString *matchingKey = [self
                             firstColorKeyForPartialString:string];
    if (matchingKey) {
        *obj = [colorList colorWithKey:matchingKey];
        return YES;
    } else {
            // Occasionally, 'errorString' is NULL
        if (errorString != NULL) {
            *errorString = [NSString stringWithFormat:
                            @"%@ is not a color", string];
        }
        return NO;
    }
}

//To make the formatter check the string after every keystroke
//Here partial is the string, including the last keystroke. If your formatter returns NO, it
//indicates that the partial string is not acceptable. Also, if your formatter returns NO, it can
//supply the newString and an errorString. The newString will appear in the control. The
//errorString should give the user an idea of what she or he did wrong. If your formatter
//returns YES, the newString and the errorString are ignored.
//- (BOOL)isPartialStringValid:(NSString *)partial
//newEditingString:(NSString **)newString
//errorDescription:(NSString **)error
//{
//        // Zero-length strings are OK
//    if ([partial length] == 0){
//        return YES;
//    }
//    NSString *match = [self
//                       firstColorKeyForPartialString:partial];
//    if (match) {
//        return YES;
//    } else {
//        if (error) {
//            *error = @"No such color";
//        }
//        return NO;
//    }
//}


//To enable autocompletion, you need to control the range of the selection as well.
- (BOOL)isPartialStringValid:(NSString **)partial
proposedSelectedRange:(NSRange *)selPtr
originalString:(NSString *)origString
originalSelectedRange:(NSRange)origSel
errorDescription:(NSString **)error
{
        // Zero-length strings are fine
    if ([*partial length] == 0) {
        return YES;
    }
    NSString *match = [self
                       firstColorKeyForPartialString:*partial];
        // No color match?
    if (!match) {
        return NO;
    }
        // If this would not move the beginning of the selection, it
        // is a delete
    if (origSel.location == selPtr->location) {
        return YES;
    }
        // If the partial string is shorter than the
        // match, provide the match and set the selection
    if ([match length] != [*partial length]) {
        selPtr->location = [*partial length];
        selPtr->length = [match length] - selPtr->location;
        *partial = match;
        return NO;
    }
    return YES;
}

//Implement the following method to display the name of the color in that color
- (NSAttributedString *)attributedStringForObjectValue:
(id)anObj
withDefaultAttributes:
(NSDictionary *)attributes
{
    NSString *match = [self
                       stringForObjectValue:anObj];
    if (!match) {
        return nil;
    }
    NSMutableDictionary *attDict = [attributes
                                    mutableCopy];
    [attDict setObject:anObj
                forKey:NSForegroundColorAttributeName];
    NSAttributedString *atString
    = [[NSAttributedString alloc]
       initWithString:match
       attributes:attDict];
    return atString;
}

@end
