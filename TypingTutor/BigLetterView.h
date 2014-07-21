//
//  BigLetterView.h
//  TypingTutor
//
//  Created by Meng Li on 14-7-16.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BigLetterView : NSView{
    //background color for customer view.
    NSColor *bgColor;
    //input string.
    NSString *string;
    //Hold the attributes dictionary and declare prepareAttributes.
    NSMutableDictionary *attributes;
    //hold mouse down event.
    NSEvent *mouseDownEvent;
    BOOL highlighted;
}

- (void)prepareAttributes;
- (IBAction)savePDF:(id)sender;

@property (strong) NSColor *bgColor;
@property (copy) NSString *string;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@end
