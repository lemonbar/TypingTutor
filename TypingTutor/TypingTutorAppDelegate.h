//
//  TypingTutorAppDelegate.h
//  TypingTutor
//
//  Created by Meng Li on 14-7-16.
//  Copyright (c) 2014年 Meng Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TypingTutorAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
