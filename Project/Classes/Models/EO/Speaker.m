// 
//  Speaker.m
//  iRubyKaigiTest
//
//  Created by Katsuyoshi Ito on 10/06/01.
//  Copyright 2010 ITO SOFT DESIGN Inc. All rights reserved.
//

#import "Speaker.h"
#import "CiderCoreData.h"
#import "LightningTalk.h"
#import "Region.h"
#import "Session.h"
#import "CiderCoreData.h"


@implementation Speaker 

@dynamic name;
@dynamic code;
@dynamic belonging;
@dynamic position;
@dynamic lightningTalks;
@dynamic sessions;
@dynamic region;


+ (Speaker *)speakerWithCode:(NSString *)code region:(Region *)region inManagedObjectContext:(NSManagedObjectContext *)context
{
    ISFetchRequestCondition *condition = [ISFetchRequestCondition fetchRequestCondition];
    condition.predicate = [NSPredicate predicateWithFormat:@"region = %@ and code = %@", region, code];
    condition.managedObjectContext = context;
    Speaker *speaker = [Speaker find:condition error:NULL];
    if (speaker == nil) {
        speaker = [Speaker createWithManagedObjectContext:context];
        speaker.code = code;
        speaker.region = region;
    }
    return speaker;
}


+ (Speaker *)speakerWithCode:(NSString *)code region:(Region *)region
{
    return [self speakerWithCode:code region:region inManagedObjectContext:DEFAULT_MANAGED_OBJECT_CONTEXT];
}

+ (NSString *)listScopeName
{
    return @"region";
}

+ (Speaker *)findByName:(NSString *)name
{
    return [self findByName:name inManagedObjectContext:nil];
}

+ (Speaker *)findByName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    ISFetchRequestCondition *condition = [ISFetchRequestCondition fetchRequestCondition];
    condition.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    condition.managedObjectContext = context;
    return [Speaker find:condition error:NULL];
}

- (NSString *)indexTitle
{
    return [self.name substringToIndex:1];
}

- (NSArray *)sortedSession
{
    NSArray *sortDescriptors = [NSSortDescriptor sortDescriptorsWithString:@"day.date, time"];
    return [self.sessions sortedArrayUsingDescriptors:sortDescriptors];
}



@end
