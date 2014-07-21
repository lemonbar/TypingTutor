//
//  BigLetterView.m
//  TypingTutor
//
//  Created by Meng Li on 14-7-16.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import "BigLetterView.h"
#import "NSString+FirstLetter.h"

@implementation BigLetterView

//As the designated initializer for NSView,
//initWithFrame: will be called automatically
//when an instance of your view is created.
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSLog(@"initializing view");
        [self prepareAttributes];
        bgColor = [NSColor yellowColor];
        string = @" ";
        //First, you need to declare your view a destination for the dragging of certain types.
        //NSView has a method for this purpose:
        [self registerForDraggedTypes:
         [NSArray
          arrayWithObject:NSPasteboardTypeString]];
    }
    
    return self;
}

#pragma mark Accessors

-(void)setBgColor:(NSColor *)c
{
    bgColor = c;
    //if you know that a view needs redrawing, you send the view the
    //setNeedsDisplay: message:
    //Note that setNeedsDisplay: will trigger the entire visible region of the view to be redrawn.
    //If you wanted to be more precise about which part of the view needs redrawing, you would
    //use setNeedsDisplayInRect: instead
    [self setNeedsDisplay:YES];
}

-(NSColor *)bgColor
{
    return bgColor;
}

-(void)setString:(NSString *)s
{
    [s retain];
    [string release];
    string = s;
    NSLog(@"The string is now %@", string);
    [self setNeedsDisplay:YES];
}

-(NSString *)string
{
    return string;
}

//When a view needs to draw itself, it is sent the message drawRect: with the rectangle that
//needs to be drawn or redrawn. The method is called automatically—you never need to call it
//directly.
- (void)drawRect:(NSRect)dirtyRect
{
    //NSRect is a struct with two members: origin, which is an
    //NSPoint, and size, which is an NSSize.
    NSRect bounds = [self bounds];
    if (highlighted) {
        NSGradient *gr;
        gr = [[NSGradient alloc] initWithStartingColor:
              [NSColor whiteColor]
                                           endingColor:bgColor];
        [gr drawInRect:bounds
relativeCenterPosition:NSZeroPoint];
    } else {
        [bgColor set];
            //You can use NSBezierPath to draw lines, circles, curves, and rectangles. You can use
            //NSImage to create composite images on the view.
        [NSBezierPath fillRect:bounds];
    }

    [self drawStringCenteredIn:bounds];
    
    // Am I the window's first responder?
    if ([[self window] firstResponder] == self && [NSGraphicsContext
                                                   currentContextDrawingToScreen]) {
//        [[NSColor keyboardFocusIndicatorColor] set];
//        [NSBezierPath setDefaultLineWidth:4.0];
//        [NSBezierPath strokeRect:bounds];
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [NSBezierPath fillRect:bounds];
        [NSGraphicsContext restoreGraphicsState];
    }
}

//The system can optimize your drawing a bit if it knows that the view is completely opaque.
//Override NSView’s isOpaque method
- (BOOL)isOpaque
{
    return YES;
}

//inherited from NSResponder
//Overridden by a subclass to return YES if it handles keyboard events.
- (BOOL)acceptsFirstResponder
{
    NSLog(@"Accepting");
    return YES;
}

//inherited from NSResponder
//Asks whether the receiver is willing to give up first-responder status.
- (BOOL)resignFirstResponder
{
    NSLog(@"Resigning");
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
//    [self setNeedsDisplay:YES];
    return YES;
}

//inherited from NSResponder
//Notifies the receiver that it has become first responder in its NSWindow.
- (BOOL)becomeFirstResponder
{
    NSLog(@"Becoming");
    [self setNeedsDisplay:YES];
    return YES;
}

//Informs the receiver that the user has pressed a key.
- (void)keyDown:(NSEvent *)event
{
    //NSResponder (from which NSView inherits) has a method called interpretKeyEvents:
    //For most key events, it just tells the view to insert the text.
    //For events that might do something else (such as Tab or Shift-Tab),
    //it calls methods on itself.
    [self interpretKeyEvents:[NSArray
                              arrayWithObject:event]];
}

- (void)insertText:(NSString *)input
{
    // Set string to be what the user typed
    [self setString:input];
}

//interpretKeyEvents: will call this method.
- (void)insertTab:(id)sender
{
    [[self window] selectKeyViewFollowingView:self];
}

//interpretKeyEvents: will call this method.
//Be careful with capitalization here, "backtab" is considered one word.
- (void)insertBacktab:(id)sender
{
    [[self window] selectKeyViewPrecedingView:self];
}

//interpretKeyEvents: will call this method.
- (void)deleteBackward:(id)sender
{
    [self setString:@" "];
}

- (void)prepareAttributes
{
    attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSFont userFontOfSize:75]
                   forKey:NSFontAttributeName];
    [attributes setObject:[NSColor redColor]
                   forKey:NSForegroundColorAttributeName];
    //avoid zombies object.
    [attributes retain];
}

//display the string in the middle of a rectangle
- (void)drawStringCenteredIn:(NSRect)r
{
    NSSize strSize = [string sizeWithAttributes:attributes];
    NSPoint strOrigin;
    strOrigin.x = r.origin.x + (r.size.width - strSize.width)/2;
    strOrigin.y = r.origin.y + (r.size.height - strSize.height)/2;
    [string drawAtPoint:strOrigin withAttributes:attributes];
}

- (IBAction)savePDF:(id)sender
{
    __block NSSavePanel *panel = [NSSavePanel
                                  savePanel];
    [panel setAllowedFileTypes:[NSArray
                                arrayWithObject:@"pdf"]];
    [panel beginSheetModalForWindow:[self window]
                  completionHandler:^ (NSInteger
                                       result) {
                      if (result == NSOKButton)
                          {
                          NSRect r = [self bounds];
                          NSData *data = [self
                                          dataWithPDFInsideRect:r];
                          NSError *error;
                          BOOL successful = [data writeToURL:[panel
                                                              URL]
                                                     options:0
                                                       error:&error];
                          if (!successful) {
                              NSAlert *a = [NSAlert
                                            alertWithError:error];
                              [a runModal];
                          }
                          }
                      panel = nil; // avoid strong ref cycle
                  }];
}

- (void)writeToPasteboard:(NSPasteboard *)pb
{
    // Copy data to the pasteboard
    [pb clearContents];
    [pb writeObjects:[NSArray arrayWithObject:string]];
}
- (BOOL)readFromPasteboard:(NSPasteboard *)pb
{
    NSArray *classes = [NSArray arrayWithObject:
                        [NSString class]];
    NSArray *objects = [pb
                        readObjectsForClasses:classes
                        options:nil];
    if ([objects count] > 0)
        {
////            // Read the string from the pasteboard
////        NSString *value = [objects objectAtIndex:0];
////            // Our view can handle only one letter
////        if ([value length] == 1) {
////            [self setString:value];
////            return YES;
//        }
        // Read the string from the pasteboard
        NSString *value = [objects objectAtIndex:0];
        [self setString:[value bnr_firstLetter]];
        return YES;
        }
    return NO;
}

- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self setString:@""];
}
- (IBAction)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard
                        generalPasteboard];
    [self writeToPasteboard:pb];
}
- (IBAction)paste:(id)sender
{
    NSPasteboard *pb = [NSPasteboard
                        generalPasteboard];
    if(![self readFromPasteboard:pb]) {
        NSBeep();
    }
}

- (void)mouseDown:(NSEvent *)event
{
    mouseDownEvent = event;
    [mouseDownEvent retain];
}

//To be a drag source, your view must implement draggingSourceOperationMaskForLocal
//declares what operations the view is willing to participate in as a source.
- (NSDragOperation)draggingSourceOperationMaskForLocal:
(BOOL)isLocal
{
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint down = [mouseDownEvent locationInWindow];
    NSPoint drag = [event locationInWindow];
    float distance = hypot(down.x - drag.x, down.y -
                           drag.y);
    if (distance < 3) {
        return;
    }
        // Is the string of zero length?
    if ([string length] == 0) {
        return;
    }
    // Get the size of the string
    NSSize s = [string sizeWithAttributes:attributes];
    // Create the image that will be dragged
    NSImage *anImage = [[NSImage alloc]
                        initWithSize:s];
    // Create a rect in which you will draw the letter
    // in the image
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    //To make the drawing appear on the image instead of on the screen, you must first lock
    //focus on the image. When the drawing is complete, you must unlock the focus.
        // Draw the letter on the image
    [anImage lockFocus];
    [self drawStringCenteredIn:imageBounds];
    [anImage unlockFocus];
        // Get the location of the mouseDown event
    NSPoint p = [self convertPoint:down fromView:nil];
        // Drag from the center of the image
    p.x = p.x - s.width/2;
    p.y = p.y - s.height/2;
        // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard
                        pasteboardWithName:NSDragPboard];
        // Put the string on the pasteboard
    [self writeToPasteboard:pb];
    // Start the drag
    //You will supply the method with the image to be dragged and the point at which you want the
    //drag to begin. The event supplied should be the mouseDown event. The offset is completely
    //ignored. The pasteboard is usually the standard drag pasteboard. If the drop does not occur,
    //you can choose whether the icon should slide back to the place from which it came.
    [self dragImage:anImage
                 at:p
             offset:NSZeroSize
              event:mouseDownEvent
         pasteboard:pb
             source:self
          slideBack:YES];
}

//When a drop occurs, the drag source will be notified if you implement the following method
- (void)draggedImage:(NSImage *)image
             endedAt:(NSPoint)screenPoint
           operation:(NSDragOperation)operation
{
    if (operation == NSDragOperationDelete) {
        [self setString:@""];
    }
}

#pragma mark Dragging Destination
//All the dragging destination methods expect an
//object that conforms to the NSDraggingInfo protocol.

//Then you need to implement six methods. All six methods have the same
//argument: an object that conforms to the NSDraggingInfo protocol.
//That object has the dragging pasteboard.

//As the image is dragged into the destination,
//the destination is sent a draggingEntered: message.
//Often, the destination view updates its appearance.
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingEntered:");
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    highlighted = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

//While the image remains within the destination, a series of
//draggingUpdated: messages are sent. Implementing
//draggingUpdated: is optional.

//If the image is dragged outside the destination, draggingExited:
//is sent.
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    NSLog(@"draggingExited:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}

//If the image is released on the destination, either it slides back to
//its source (and breaks the sequence) or a
//prepareForDragOperation: message is sent to the destination,
//depending on the value returned by the most recent invocation of
//draggingEntered: (or draggingUpdated: if the view implemented it).

//If the prepareForDragOperation: message returns YES, then a
//performDragOperation: message is sent. This is typically where
//the application reads data off the pasteboard.
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>) sender
{
    return YES;
}

//If the prepareForDragOperation: message returns YES, then a
//performDragOperation: message is sent. This is typically where
//the application reads data off the pasteboard.
- (BOOL)performDragOperation:(id <NSDraggingInfo>) sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if(![self readFromPasteboard:pb]) {
        NSLog(@"Error: Could not read from dragging pasteboard");
        return NO;
    }
    return YES;
}

//if performDragOperation: returned YES,
//concludeDragOperation: is sent. The appearance may change.
//This is where you might generate the big gulping sound that implies
//a successful drop.
- (void)concludeDragOperation:(id <NSDraggingInfo>) sender
{
    NSLog(@"concludeDragOperation:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}

//It will get the source’s advertised
//operation mask and filter it, depending on what modifier keys the user holds down.
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSDragOperation op = [sender
                          draggingSourceOperationMask];
    NSLog(@"operation mask = %ld", op);
    if ([sender draggingSource] == self) {
        return NSDragOperationNone;
    }
    return NSDragOperationCopy;
}

@end
