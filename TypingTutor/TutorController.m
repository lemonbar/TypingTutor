//
//  TutorController.m
//  TypingTutor
//
//  Created by Meng Li on 14-7-17.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import "TutorController.h"
#import "BigLetterView.h"

@implementation TutorController

- (id)init
{
    self = [super init];
    if (self) {
            // Create an array of letters
        letters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",
                   @"e",@"f", @"g",@"h",@"i",@"j", @"k", @"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",
                   nil];
        [letters retain];
        // Seed the random number generator
        srandom((unsigned)time(NULL));
        timeLimit = 5.0;
    }
    return self;
}

- (void)awakeFromNib
{
    [self showAnotherLetter];
}

- (void)resetElapsedTime
{
    startTime = [NSDate
                 timeIntervalSinceReferenceDate];
    [self updateElapsedTime];
}

- (void)updateElapsedTime
{
    [self willChangeValueForKey:@"elapsedTime"];
    elapsedTime = [NSDate
                   timeIntervalSinceReferenceDate] - startTime;
    [self didChangeValueForKey:@"elapsedTime"];
}

- (void)showAnotherLetter
{
    //Choose random numbers until you get a different
    // number than last time
    int x = lastIndex;
    while (x == lastIndex){
        x = (int)(random() % [letters count]);
    }
    lastIndex = x;
    [outLetterView setString:[letters
                              objectAtIndex:x]];
    // Start the count again
    [self resetElapsedTime];
}

- (IBAction)stopGo:(id)sender
{
    [self resetElapsedTime];
    if (timer == nil) {
        NSLog(@"Starting");
            // Create a timer
        timer = [NSTimer
                 scheduledTimerWithTimeInterval:0.1
                 target:self
                 selector:@selector(checkThem:)
                 userInfo:nil
                 repeats:YES];
    } else {
        NSLog(@"Stopping");
        // Invalidate the timer
        [timer invalidate];
        timer = nil;
    }
}

- (void)checkThem:(NSTimer *)aTimer
{
    if ([[inLetterView string] isEqual:[outLetterView
                                        string]]) {
        [self showAnotherLetter];
    }
    [self updateElapsedTime];
    if (elapsedTime >= timeLimit) {
        NSBeep();
        [self resetElapsedTime];
    }
}

- (IBAction)showSpeedSheet:(id)sender
{
    [NSApp beginSheet:speedSheet
       modalForWindow:[inLetterView window]
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)endSpeedSheet:(id)sender
{
        // Return to normal event handling
    [NSApp endSheet:speedSheet];
        // Hide the sheet
    [speedSheet orderOut:sender];
}

- (BOOL)control:(NSControl *)control
didFailToFormatString:(NSString *)string
errorDescription:(NSString *)error
{
    NSLog(@"TutorController told that formatting of %@ failed: %@",
          string, error);
    return NO;
}

@end