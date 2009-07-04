//
//  Document.m
//  RubyKaigi2009
//
//  Created by Katsuyoshi Ito on 09/06/25.
//  Copyright 2009 ITO SOFT DESIGN Inc. All rights reserved.
//

#import "Document.h"
#import "NSManagedObjectContextExtension.h"

@implementation Document


+ (Document *)sharedDocument
{
    static Document *document = nil;
    if (document == nil) {
        document = [Document new];
    }
    return document;
}


- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [super dealloc];   
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RubyKaigi2009.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}



#pragma mark -
#pragma mark data access

+ (NSDate *)dateFromString:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:dateStr];
}


- (NSManagedObject *)dayForDate:(NSString *)dateStr
{
    NSDate *date = [[self class] dateFromString:dateStr];
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", date];
    [request setPredicate:predicate];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count]) {
        return [result lastObject];
    } else {
        NSManagedObject *eo = [NSEntityDescription insertNewObjectForEntityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
        [eo setValue:date forKey:@"date"];
        return eo;
    }
}

- (NSManagedObject *)roomForName:(NSString *)name floor:(NSString *)floor
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Room" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ and floor = %@", name, floor];
    [request setPredicate:predicate];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count]) {
        return [result lastObject];
    } else {
        NSManagedObject *eo = [NSEntityDescription insertNewObjectForEntityForName:@"Room" inManagedObjectContext:self.managedObjectContext];
        [eo setValue:name forKey:@"name"];
        [eo setValue:floor forKey:@"floor"];

        [request setPredicate:nil];
        int count = [self.managedObjectContext countForFetchRequest:request error:&error];
        [eo setValue:[NSNumber numberWithInt:count - 1] forKey:@"position"];
        
        return eo;
    }
}

- (NSArray *)days
{
    PredicateCondition *condition = [PredicateCondition conditionWithEntity:@"Day" format:nil argumentArray:nil];
    condition.orderings = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease]];
    return [self.managedObjectContext findAll:condition];
}

- (NSArray *)sessions
{
    PredicateCondition *condition = [PredicateCondition conditionWithEntity:@"Session" format:nil argumentArray:nil];
    return [self.managedObjectContext findAll:condition];
}

- (NSArray *)rooms
{
    PredicateCondition *condition = [PredicateCondition conditionWithEntity:@"Room" format:nil argumentArray:nil];
    return [self.managedObjectContext findAll:condition];
}




#pragma mark -
#pragma mark import datas

- (void)importFromCsvFile:(NSString *)fileName
{
    NSString *contents = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
    BOOL isFirst = YES;
    NSArray *keys;
    int position = 0;
    for (NSString *line in [contents componentsSeparatedByString:@"\n"]) {
        if ([line length]) {
            if (isFirst) {
                isFirst = NO;
                keys = [line componentsSeparatedByString:@","];
            } else {
                int index = 0;
                NSManagedObject *eo = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
                [eo setValue:[NSNumber numberWithInt:position++] forKey:@"position"];
                
                NSManagedObject *day;
                NSString *roomName = nil;
                NSString *floorName = nil;
                for (NSString *element in [line componentsSeparatedByString:@","]) {
                    NSString *key = [keys objectAtIndex:index];
                    if ([key isEqualToString:@"date"]) {
                        day = [self dayForDate:element];
                        [[day  mutableSetValueForKey:@"sessions"] addObject:eo];
                    } else
                    if ([key isEqualToString:@"room"]) {
                        roomName = element;
                    } else
                    if ([key isEqualToString:@"floor"]) {
                        floorName = element;
                    } else
                    if ([key isEqualToString:@"break"]) {
                        [eo setValue:[NSNumber numberWithBool:[element isEqualToString:@"true"]] forKey:key];
                    } else {
                        [eo setValue:element forKey:key];
                    }

                    if ([roomName length] && [floorName length] && ![[eo valueForKey:@"break"] boolValue]) {
                        NSManagedObject *room = [self roomForName:roomName floor:floorName];
                        [eo setValue:room forKey:@"room"];
                        roomName = floorName = nil;
                    }

                    index++;
                }
                NSLog(@"%@", eo);
            }
        }
    }
}

@end