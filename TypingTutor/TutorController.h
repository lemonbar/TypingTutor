//
//  TutorController.h
//  TypingTutor
//
//  Created by Meng Li on 14-7-17.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BigLetterView;

@interface TutorController : NSObject{
        //bigletterviews
    IBOutlet BigLetterView *inLetterView;
    IBOutlet BigLetterView *outLetterView;
    IBOutlet NSWindow *speedSheet;
    
        //data
    NSArray *letters;
    int lastIndex;
    
        // Time
    NSTimeInterval startTime;
    NSTimeInterval elapsedTime;
    NSTimeInterval timeLimit;
    NSTimer *timer;
}

- (IBAction)stopGo:(id)sender;
- (IBAction)showSpeedSheet:(id)sender;
- (IBAction)endSpeedSheet:(id)sender;

- (void)updateElapsedTime;
- (void)resetElapsedTime;
- (void)showAnotherLetter;

@end
